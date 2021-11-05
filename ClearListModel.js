WorkerScript.onMessage = function(message)
{
    // Clear ListModel
    message.model.clear();
    message.model.sync();  // Updates the changes to the ListView

    // Response to main thread
    WorkerScript.sendMessage({});
}
