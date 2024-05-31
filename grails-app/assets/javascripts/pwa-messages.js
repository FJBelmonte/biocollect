window.addEventListener('message', function(event) {
    var origins = [fcConfig.originUrl, fcConfig.pwaAppUrl, "http://localhost:8081"]
    if (origins.indexOf(event.origin) == -1)
        return

    var type = event.data.event;
    switch (type) {
        case 'viewmodelloadded':
            // fired by the iframe when the view model is loaded
            var viewModelLoadedEvent = new Event('view-model-loaded');
            document.dispatchEvent(viewModelLoadedEvent);
            break;
        case 'credentials':
            entities.saveCredentials(event.data.data).then(function (){
                var credentialSavedEvent = new Event('credential-saved');
                document.dispatchEvent(credentialSavedEvent);
            }, function (){
                var credentialFailedEvent = new Event('credential-failed');
                document.dispatchEvent(credentialFailedEvent);
            });
            break;
    }

})