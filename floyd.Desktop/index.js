
$(function() {
    var startupView = "View1";

    DevExpress.devices.current("desktop");

    floyd.app = new DevExpress.framework.html.HtmlApplication({
        namespace: floyd,
        layoutSet: DevExpress.framework.html.layoutSets[floyd.config.layoutSet],
        mode: "webSite",
        navigation: floyd.config.navigation,
        commandMapping: floyd.config.commandMapping
    });

    $(window).unload(function() {
        floyd.app.saveState();
    });

    floyd.app.router.register(":view/:id", { view: startupView, id: undefined });
    floyd.app.navigate();
});