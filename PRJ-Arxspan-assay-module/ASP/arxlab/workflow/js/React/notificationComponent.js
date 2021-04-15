/**
 * JSX Title component for a notification.
 * @param {object} props Holds the title, author and date of this notification.
 */
function NotificationTitle(props) {
    return (
        <div>
            <h4 className="reactNotificationTitle">{props.title}</h4>
            <div className="reactNotificationAuthor"><b>{props.author}</b></div>
            <div className="reactNotificationTime">{props.date}</div>
        </div>
    )
}

/**
 * JSX Text component for a string-based notification.
 * @param {object} props Holds the propkey and contents for the notification.
 */
function NotificationTextBody(props) {
    return <div key={props.propkey}>{props.body}</div>;
}

/**
 * JSX Component to display an image.
 * @param {object} props Contains the image source.
 */
function NotificationImgCell(props) {
    return <img src={props.body}/>;
}

/**
 * Converts an SVG into a base64 image so the results can be passed through to the NotificationImgCell to be displayed.
 * @param {object} props Contains the SVG image.
 */
function NotificationSvgCell(props) {
    var base64svg = btoa(props.body);
    return <NotificationImgCell body={`data:image/svg+xml;base64,${base64svg}`} />;
}

/**
 * JSX Component to display a field cell.
 * @param {object} props 
 */
function NotificationCell(props) {
    var cell = <span>{props.text}</span>;

    if (props.text) {
        if (props.text.toString().includes("data:image/png;base64")) {
            cell = <NotificationImgCell body={props.text}></NotificationImgCell>
        } else if (props.text.toString().includes("<svg")) {
            cell = <NotificationSvgCell body={props.text}></NotificationSvgCell>
        } else {
            cell = <span>{utilities().stripHtml(props.text)}</span>
        }
    }

    return cell;
}

/**
 * JSX Component to display a field name.
 * @param {object} props Contains the field name.
 */
function NotificationFieldName(props) {
    return (
        <tr>
            <td className="reactNotificationFieldName">
                <b>{props.title}</b>
            </td>
        </tr>
    );
}

/**
 * JSX Component to display a field update row.
 * @param {object} props Contains the old and new values of the field.
 */
function NotificationTableRow(props) {
    return (
        <tr>
            <td className="reactNotificationFieldTableCell">
                <NotificationCell text={props.oldValue} />
            </td>
            <td className="reactNotificationFieldTableCell reactNotificationFieldTableCellRight">
                <NotificationCell text={props.newValue} />
            </td>
        </tr>
    )
}

/**
 * JSX Component to display an update notification.
 * @param {object} props Contains the title and data for one field update notification.
 */
function NotificationUpdateTable(props) {
    var notificationRows = [<NotificationFieldName title={props.title} key={0} />];
    notificationRows = notificationRows.concat(
        props.data.map(x => <NotificationTableRow oldValue={x.oldValue} newValue={x.newValue} key={props.data.indexOf(x) + 1} />)
    )

    return (
        <table className="reactNotificationFieldTable">
            <tbody>
                {notificationRows}
            </tbody>
        </table>
    );
}

/**
 * JSX Component to display a regained priority notification.
 * @param {object} props Contains the assignedOrder and requestedOrders for the request.
 */
function NotificationRegainedPriorityTable(props) {
    return (
        <table className="reactNotificationFieldTable">
            <tbody>
                <NotificationTableRow oldValue={props.data.assignedOrder} newValue={props.data.requestedOrder} />
            </tbody>
        </table>
    );
}

/**
 * JSX Component for the reprioritization table header for the Manage Requests notifications.
 * @param {object} props Contains the type of reprioritization notification this header will go to.
 */
function NotificationReprioritizationHeader(props) {
    return (
        <thead>
            <tr>
                <th className="reactNotificationTableCell">Request Name</th>
                <th className="reactNotificationTableCell">Old {props.type}</th>
                <th className="reactNotificationTableCell">New {props.type}</th>
            </tr>
        </thead>
    );
}

/**
 * JSX component to display reprioritization notifications.
 * @param {object} props Contains the notification key and the notification row data.
 */
function NotificationPrioritizationTable(props) {

    var isRequestedOrder = props.pagemode == "RequestedOrder";
    var headerType = isRequestedOrder ? "Priority" : "Start Order";
    var columnHeaders = <NotificationReprioritizationHeader type={headerType} />;
    var notificationTitle = isRequestedOrder ? "Updated Priorities" : "Updated Start Orders";

    return (
        <div key={props.propkey}>
            <span>{notificationTitle}</span>
            <table className="reactNotificationTable">
                {columnHeaders}
                <tbody>
                    {props.body.map(function(row) {
                        var oldVal = row["old"] || row["oldValue"];
                        var newVal = row["new"] || row["newValue"];

                        return <tr
                                    key={props.body.indexOf(row)}
                                >
                            <td className="reactNotificationTableCell">{row.name}</td>
                            <td className="reactNotificationTableCell">{oldVal}</td>
                            <td className="reactNotificationTableCell">{newVal}</td>
                        </tr>
                    })}
                </tbody>
            </table>
        </div>
    )
}

function DismissNotificationButton(props) {
    return (
        <div className="reactDismissNotificationButtonHolder">
            <i
                onClick={props.removeNotificationFn}
                index={props.index}
                className="reactDismissNotificationButton fa fa-times"
                aria-hidden="true"
                title="Dismiss notification"
            >
            </i>
        </div>
    )
}

function DismissAllBtn(props) {
    return (
        <div
            onClick={props.dismissAllFn}
            className="dismissAllBtn fa fa-trash"
            title="Dismiss All Notifications"
        >
        </div>
    )
}

/**
 * JSX component to hold a single notification.
 * @param {object} props The notification object retrieved from the notification service.
 */
function NotificationHolder(props) {

    var notificationTitle = props.title;
    var notificationAuthor = props.author;
    var notificationDate = props.date;
    var notificationType = getTypeOfNotification(props.body);

    var notificationLink = "#";
    var notificationTarget = null;
    var notificationTitleText = null;
    var isRequestLink = false;

    if (notificationType == "prioritization") {
        var isRequestedOrder = getPageModeOfReprioritizationNotification(props.body) == "RequestedOrder";
        notificationLink = isRequestedOrder ? `index.asp` : `manageRequests.asp`;
        notificationTarget = isRequestLink ? "_blank" : notificationTarget;
        notificationTitleText = isRequestedOrder ? "Click Here to go to My Requests" : "Click Here to go to Manage Requests";
    } else if (notificationType == "regained priority") {
        isRequestLink = props.requestId > 0;
        notificationTitle = `${notificationTitle} has regained priority.`;
        notificationTitleText = isRequestLink ? "Click Here to View this Request" : notificationTitleText;
    } else {
        isRequestLink = props.requestId > 0;
        notificationLink = isRequestLink ? `viewIndividualRequest.asp?requestid=${props.requestId}` : notificationLink;
        notificationTarget = isRequestLink ? "_blank" : notificationTarget;
        notificationTitleText = isRequestLink ? "Click Here to View this Request" : notificationTitleText;
    }

    var dismissBtn = <DismissNotificationButton
                        removeNotificationFn={props.removeNotificationFn}
                        index={props.index}
                    />;

    var titleHolder = <NotificationTitle 
                        title={notificationTitle}
                        author={notificationAuthor}
                        date={notificationDate}
                    />;
        
    var bodyHolder = <NotificationBody
                        body={props.body} 
                        type={notificationType}
                    />;

    return (
        <div
            className="reactNotificationHolder"
        >
            {dismissBtn}
            <a
                className="reactNotificationLink"
                href={notificationLink}
                target={notificationTarget}
                title={notificationTitleText}
            >
                {titleHolder}
                {bodyHolder}
            </a>
        </div>
    );
}

/**
 * Parse the given notification body and return the appropriate number of JSX components based on notificaitonBody.
 * @param {object} props The notification to parse.
 */
function NotificationBody(props) {
    var parsedNotification = null;
    var tableHead = null;

    var notificationBody = props.body;
    var notificationType = props.type;

    if (notificationType == "table") {
        tableHead = <UpdateNotificationTableHead />;
    } else if (notificationType == "regained priority") {
        tableHead = <RegainedPriorityTableHead />;
    }
    
    if (Array.isArray(notificationBody)) {
        parsedNotification = notificationBody
        .map(x => 
            <NotificationObj
                data={x.data}
                type={x.type}
                displayName={x.displayName}
                pagemode={x.pageMode}
                key={notificationBody.indexOf(x)}
                propkey={notificationBody.indexOf(x)}
            />
        );
    } else {
        parsedNotification = <NotificationObj
            data={notificationBody.data}
            type={notificationBody.type}
            displayName={notificationBody.displayName}
            pagemode={notificationBody.pageMode}
            propkey={0}
        />;
    }

    return (
        <div>
            {tableHead}
            {parsedNotification}
        </div>
    );
}

/**
 * Parse the given notification object out into the appropriate notification type.
 * @param {*} notificationBody The notification data to parse.
 * @param {*} key The key for this notification.
 */
function NotificationObj(props) {//notificationBody, key) {
    var parsedNotification = null;
    if (props.type == "string") {

        parsedNotification = <NotificationTextBody
                                body={props.data}
                                propkey={props.propkey}
                                key={props.propkey}
                            />;

    } else if (props.type == "table") {

        parsedNotification = <NotificationUpdateTable
                                data={props.data}
                                title={props.displayName}
                                key={props.propkey}
                            />;

    } else if (props.type == "regained priority") {
        
        parsedNotification = <NotificationRegainedPriorityTable
                                data={props.data}
                                propkey={props.propkey}
                                key={props.propkey}
                            />;

    } else if (props.type == "prioritization") {

        parsedNotification = <NotificationPrioritizationTable
                                body={props.data}
                                pagemode={props.pagemode}
                                propkey={props.propkey}
                                key={props.propkey}
                            />;

    }
    return parsedNotification;
}

/**
 * JSX component to display the table header for update notifications
 */
function UpdateNotificationTableHead() {
    return (
        <table className="reactNotificationTableHead">
            <thead>
                <tr>
                    <th className="reactNotificationTableHeadCell">Old Values</th>
                    <th className="reactNotificationTableHeadCell">New Values</th>
                </tr>
            </thead>
        </table>
    )
}

/**
 * JSX component to display the table header for regained priority notifications
 */
function RegainedPriorityTableHead() {
    return (
        <table className="reactNotificationTableHead">
            <thead>
                <tr>
                    <th className="reactNotificationTableHeadCell">Assigned Order</th>
                    <th className="reactNotificationTableHeadCell">Requested Order</th>
                </tr>
            </thead>
        </table>
    )
}

/**
 * Interrogates the notificationBody to figure out what type it is.
 * @param {*} notificationBody The notification data to interrogate.
 */
function getTypeOfNotification(notificationBody) {
    var notificationType = "";
    if (Array.isArray(notificationBody)) {
        notificationType = notificationBody[0].type;
    } else {
        notificationType = notificationBody.type;
    }
    return notificationType;
}

/**
 * Interrogates the notificationBody from a reprioritization notification to figure out what page it came from.
 * @param {*} notificationBody The notification data to interrogate.
 */
function getPageModeOfReprioritizationNotification(notificationBody) {
    var pageMode = "RequestedOrder";
    if (Array.isArray(notificationBody)) {
        pageMode = notificationBody[0].pageMode;
    } else {
        pageMode = notificationBody.pageMode;
    }
    return pageMode;
}

class NotificationContainer extends React.Component {
    
    constructor(props) {
        super(props);

        this.state = {
            notifications: this.props.notifications
        };
    }

    renderNotificationHolder(notificationObj) {

        var notification = JSON.parse(notificationObj.notificationJson);
        var thisDate = new Date(notification.date);
        var thisDateHours = thisDate.getHours();
        thisDateHours = thisDateHours < 10 ? `0${thisDateHours.toString()}` : thisDateHours;
        var thisDateMinutes = thisDate.getMinutes();
        thisDateMinutes = thisDateMinutes < 10 ? `0${thisDateMinutes.toString()}` : thisDateMinutes;
        var thisDateSeconds = thisDate.getSeconds();
        thisDateSeconds = thisDateSeconds < 10 ? `0${thisDateSeconds.toString()}` : thisDateSeconds;
        var thisDateStr = `${thisDate.getMonth() + 1}/${thisDate.getDate()}/${thisDate.getFullYear()} ${thisDateHours}:${thisDateMinutes}:${thisDateSeconds}`;
        return (
            <NotificationHolder
                title={notification.title}
                author={notification.author}
                date={thisDateStr}
                body={notification.body}
                key={notificationObj.id}
                index={notificationObj.id}
                requestId={notification.requestId}
                removeNotificationFn={(i) => this.clickDismissButton(i)}
            />
        )
    }

    renderDismissAllBtn(dismissAllFn) {
        return (
            <DismissAllBtn dismissAllFn={() => dismissAllFn()}></DismissAllBtn>
        )
    }

    clickDismissButton(evt) {
        var thisKey = evt.target.getAttribute("index");
        var currNotifications = this.state.notifications;
        var thisNotification = currNotifications.find(x => x.id == thisKey);

        removeNotification(thisNotification);

        var filteredNotifications = currNotifications.filter(x => x.id != thisKey);

        $($(evt.target).parent()).parent().fadeOut(fadeTime);

        var timeoutThis = this;
        var timeoutFunction = function() {
            timeoutThis.setState({notifications: filteredNotifications});
        }
        setTimeout(timeoutFunction, fadeTime);
        
    }

    dismissAllNotifications() {
        var currNotifications = this.state.notifications;

        $.each(currNotifications, function(notificationIndex, notification) {
            removeNotification(notification);
        });

        var timeoutThis = this;
        var timeoutFunction = function() {
            timeoutThis.setState({notifications: []});
        }
        setTimeout(timeoutFunction, fadeTime);
    }

    render() {
        var notifications = this.state.notifications.map(notification => this.renderNotificationHolder(notification), this);
        var dismissAllBtn = this.state.notifications.length > 0 ? this.renderDismissAllBtn(() => this.dismissAllNotifications()) : null;
        
        return (
            <div
                className="outerReactRequestNotificationsContainer"
            >
                <div
                    className="reactRequestNotificationsContainer"
                >
                    {notifications}
                </div>
                <div className="dismissAllBtnHolder">
                    {dismissAllBtn}
                </div>
            </div>
        )
    }
}

function mountNotificationNode(notifications) {
    if ($("#reactNotificationHolder").length > 0) {
        ReactDOM.render(<NotificationContainer notifications={notifications}></NotificationContainer>, document.getElementById("reactNotificationHolder"));
    }
}

function unmountNotificationNode() {
    if ($("#reactNotificationHolder").length > 0) {
        ReactDOM.unmountComponentAtNode(document.getElementById("reactNotificationHolder"));
    }
}

/**
 * Fades in the notification display node and fetches the list of notifications.
 */
function showNotificationNode() {    
    $("#reactNotificationHolder").fadeIn(fadeTime);
    fetchUnreadNotifications();
}

function hideNotificationNode() {
    $("#reactNotificationHolder").fadeOut(fadeTime);
}

$("#notificationsDropdownToggle").on("click", function() {
    //mountNotificationNode([]);

    if ($("#reactNotificationHolder").is(":visible")) {
        hideNotificationNode();
    } else {
        showNotificationNode();
    }

});

$(document).click(function(evt) {
    if (!$(evt.target).closest(".outerReactRequestNotificationsContainer").length) {
        hideNotificationNode();
    }
});


function removeNotification(thisNotification) {

    var notificationPatch = {
        appName: "Workflow",
        browserNotification: thisNotification,
        userId: globalUserInfo.userId
    };

    ajaxModule().patchNotification(notificationPatch);

    var browserNotificationRecipient = thisNotification.browserNotificationRecipients.find(x => x.userId == globalUserInfo.userId);

    if (browserNotificationRecipient) {
        var notificatonPatchReadDate = {
            appName: "Workflow",
            browserNotificationRecipientId: browserNotificationRecipient.id,
            userId: globalUserInfo.userId
        }

        ajaxModule().patchNotificatonReadDate(notificatonPatchReadDate);
    }

}

/**
 * Fetches the latest unread notifications from the notification svc and updates the viewer component.
 */
function fetchUnreadNotifications() {
    ajaxModule().getUnreadNotifications().then(function(notifications) {
        unmountNotificationNode();
        utilities().updateNotificationCount(notifications.length);
        mountNotificationNode(notifications);
    });
}

$(document).ready(function() {
    fetchUnreadNotifications();
});

var fadeTime = 250;