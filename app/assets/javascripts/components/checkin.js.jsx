var CheckInButton = React.createClass({
  render: function() {
    return(
      <button onClick={this.props.onclick} className="btn btn-default" >Check in Attendee</button>
    )
  }
});
 
var CheckOutButton = React.createClass({
  render: function() {
    return(
      <button onClick={this.props.onclick} className="btn btn-default" >Undo Checkin</button>
    )
  }
});

var FilterInput = React.createClass({
  cLog: function() {
    console.log("child");
  },

  render: function() {
    return (
      <div className="row">
        <div className="col-sm-4 col-sm-offset-4 col-xs-6 col-xs-offset-3">
          <input onChange={this.props.onFilter} id="attendeeName" className="form-control"></input>
        </div>
      </div>
    )
  }
});
 
var Attendee = React.createClass({
  render: function() {
    // Equivalent to _.partial(this.props.onCheckIn, this.props.attendee.guid)
    // I would usually just put that partial inline below, like:
    //     onClick={_.partial(this.props.onCheckIn, this.props.attendee.guid)}
    var onCheckIn = function(ev) {
      console.log(this.props.attendee.guid)
      return this.props.onCheckIn(this.props.attendee.guid, ev);
    }.bind(this);
    var onCheckOut = function(ev) {
      return this.props.onCheckOut(this.props.attendee.guid, ev);
    }.bind(this);
    
    // If the attendee is checked in, render it that way
    if (this.props.attendee.isCheckedIn) {
      return (
        <div className="row text-center">
          <div className="col-xs-3 col-xs-offset-1">
            {this.props.attendee.name}
          </div>
          <div className="col-xs-4">
            {this.props.attendee.ticketCount}
          </div>
          <div className="col-xs-3">
            <CheckOutButton onclick={onCheckOut} attendeeType={this.props.attendee.type} attendeeId={this.props.attendee.id} />
          </div>
        </div>
      );
    }
 
    // Otherwise, render the checked out attendee with a check-in button
    return (
      <div className="row text-center">
        <div className="col-xs-3 col-xs-offset-1">
          {this.props.attendee.name}
        </div>
        <div className="col-xs-4">
          {this.props.attendee.ticketCount}
        </div>
        <div className="col-xs-3">
          <CheckInButton onclick={onCheckIn} />
        </div>
      </div>
    );
  }
});
 
var CheckInList = React.createClass({
  getInitialState: function() {
    return {attendees: []};
  },
   
  componentDidMount: function() {
    this.updateAttendees();

  },
 
  normalizeAttendee: function(attendee) {
    var isCheckedIn = false;
    if (attendee[1][0].state == "used") {
      isCheckedIn = true;
    }
    return {
      id: attendee[1][0].ticket_owner_id,
      guid: attendee[1][0].guid,
      name: attendee[0],
      type: attendee[1][0].ticket_owner_type,
      ticketCount: attendee[1].length,
      isCheckedIn: isCheckedIn
    };
  },

  filterAttendee: function(attendee, query) {
    if (attendee.name.toLowerCase().indexOf(query.toLowerCase()) > -1) {
      return attendee
    }
  },
 
  normalizeAttendeeList: function(attendeeList) {
    return attendeeList.map(function(attendee) {
      return this.normalizeAttendee(attendee);
    }.bind(this));
  },

  filterAttendeeList: function(attendeeList, query) {
    return attendeeList.filter(function(attendee){
      return this.filterAttendee(attendee, query);
    }.bind(this));
  },
   
  updateAttendees: function() {
    $.get(this.props.source, function(result) {
      var attendeeList = this.normalizeAttendeeList(result)
      this.setState({
        attendees: attendeeList
      });
    }.bind(this));
  },

  updateAttendeesFiltered: function() {
    $.get(this.props.source, function(result) {
      var attendeeList = this.normalizeAttendeeList(result)
      var attendeeName = $('#attendeeName').val()
      var attendeeListFiltered = this.filterAttendeeList(attendeeList, attendeeName)
      this.setState({
        attendees: attendeeListFiltered
      });
    }.bind(this));
  },

  cLog: function() {
    console.log("parent");
  },
 
  handleCheckIn: function(attendeeGuid, ev) {
    console.log('Checking in attendee: ' + attendeeGuid);
    var modifiedAttendees = this.state.attendees

    for (var attendee in modifiedAttendees) {
      if (modifiedAttendees[attendee].guid == attendeeGuid && modifiedAttendees[attendee].isCheckedIn == false) {

        modifiedAttendees[attendee].isCheckedIn = true;
        $.ajax({
          type: "POST",
          url: this.props.checkInRoute,
          data: {attendee: {attendee_id: modifiedAttendees[attendee].id, attendee_type:modifiedAttendees[attendee].type}}
          // success: console.log('attendee checked in'),
          // dataType: "json"
        });
      }
    }

    this.setState({
      attendees: modifiedAttendees
    })

    // this.updateAttendees(); // removed because it would snap back
    
  },
 
  handleCheckOut: function(attendeeGuid, ev) {
    console.log('Checking out attendee: ' + attendeeGuid);
    var modifiedAttendees = this.state.attendees

    for (var attendee in modifiedAttendees) {
      if (modifiedAttendees[attendee].guid == attendeeGuid && modifiedAttendees[attendee].isCheckedIn == true) {

        modifiedAttendees[attendee].isCheckedIn = false;
        $.ajax({
          type: "POST",
          url: this.props.checkOutRoute,
          data: {attendee: {attendee_id: modifiedAttendees[attendee].id, attendee_type:modifiedAttendees[attendee].type}}
          // success: console.log('attendee checked in'),
          // dataType: "json"
        });
      }
    }

    this.setState({
      attendees: modifiedAttendees
    })

    // this.updateAttendees(); // removed because it would snap back
  },
 
  render: function() {
    return (
      <div>
        <br />
        <label>Filter Attendees by Name</label>
        <FilterInput onFilter={this.updateAttendeesFiltered} />
        <h2>Attendees</h2>
        <div className="row text-center">
          <div className="col-xs-3 col-xs-offset-1">
            <strong>Name</strong>
          </div>
          <div className="col-xs-4">
            <strong>Ticket Quantity</strong>
          </div>
          <div className="col-xs-3">
            <strong>Check In</strong>
          </div>
        </div>
        <br />
        {this.state.attendees.filter(function(el) {
          return el.isCheckedIn == false }
          ).map(function(attendee) {
          return <Attendee key={attendee.guid}
                           attendee={attendee}
                           onCheckIn={this.handleCheckIn} />;
        }.bind(this))}
        <h2>Checked In</h2>
        {this.state.attendees.filter(function(el) { return el.isCheckedIn == true }).map(function(attendee) {
          return <Attendee key={attendee.guid}
                           attendee={attendee}
                           onCheckOut={this.handleCheckOut} />;
        }.bind(this))}
      </div>
    );
  }
});