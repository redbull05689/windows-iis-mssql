
function TextBlock(props) {

    var diffs = props.diffs;

    var textLines = [];
    $.each(diffs, function(i, diff) {
        $.each(diff.value, function(j, line) {
            var elem = <div className={diff.removed || diff.added ? "diff" : ":"}>{line}</div>
            textLines.push(elem);
        });
    });

    return (
        <div className={`textBlock ${props.className}`}>
            <span>{props.title}</span>
            <pre>
                {textLines.map(x => x)}
            </pre>
        </div>
    )
}

function DiffViewer(props) {
    var oldReqTypeStr = JSON.stringify(props.oldRequestType, null, 4);
    var oldReqTypeArr = oldReqTypeStr.split("\n");

    var currReqTypeStr = JSON.stringify(props.currentRequestType, null, 4);
    var currReqTypeArr = currReqTypeStr.split("\n");

    var arrayDiffs = JsDiff.diffArrays(oldReqTypeArr, currReqTypeArr);
    var oldDiffs = arrayDiffs.filter(x => x.added == x.removed || x.removed);
    var newDiffs = arrayDiffs.filter(x => x.added == x.removed || x.added);

    return (
        <div className="textHolder">
            <TextBlock
                lines={oldReqTypeArr}
                title={`Old - From ${props.asOfDate}`}
                className="oldVersion"
                diffs={oldDiffs}
            />
            <TextBlock
                lines={currReqTypeArr}
                title="Current"
                className="currVersion"
                diffs={newDiffs}
            />
        </div>
    )
}

$(document).ready(function() {
    ajaxModule().isThisTheMostRecent(requestTypeId, asOfDate, true).then(function(response) {
        var oldRequestType = JSON.parse(response["jsonAsOf"])[0];
        var currentRequestType = JSON.parse(response["jsonCurrent"])[0];

        ReactDOM.render(<DiffViewer oldRequestType={oldRequestType} currentRequestType={currentRequestType} asOfDate={asOfDate} />, document.getElementById("diffViewer"));
    });
});