$(document).ready(function() {
    // Change this boolean if you want the file list on item-view to collapse or not at page load
    var shouldCollapseFileListAtPageLoad = true;

    if(shouldCollapseFileListAtPageLoad) {
        $("#file-section-list").slideToggle(0);
    }
});

$("#file-section-view-open").click(function() {
    $("#file-section-list").slideToggle(300);
});