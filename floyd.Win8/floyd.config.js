
// NOTE object below must be a valid JSON
window.floyd = $.extend(true, window.floyd, {
    "config": {
        "layoutSet": "empty",
        "navigation": [
            {
                "title": "Floyd",
                "action": "#View1",
                "icon": "runner",
                "root": false
            },
            {
                "title": "About",
                "action": "#About",
                "icon": "info",
                "root": false
            },
            {
                "title": "Clear",
                "action": "#View1/clear",
                "root": false
            }
        ]
    }
});
