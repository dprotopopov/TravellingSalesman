"use strict";

floyd.View1 = function(params) {

    var message = ko.observable("");

    var lastId = ko.observable(0);

    // Дефолтные значения следующего добавляемого элемента
    var nextItemId = ko.computed(function() { return parseInt(lastId()) + 1; });
    var nextItemTitle = ko.computed(function() { return "Untitled" + (parseInt(lastId()) + 1); });

    var items = ko.observableArray([]);

    var dataSourceItems = ko.observable({
        store: {
            type: 'local',
            name: "Items",
            key: "id",
            immediate: true,
            inserted: onInsertOrUpdate,
            updated: onInsertOrUpdate,
            removed: onRemoved,
        }
    });
    var dataSourcePrices = ko.observable({
        store: {
            type: 'local',
            name: "Prices",
            key: "id",
            immediate: true,
        }
    });

    var minimum = ko.observableArray([]);
    var intermedian = ko.observableArray([]);
    var path = ko.observableArray([]);

    var dataSourceMinimum = ko.observable({
        store: {
            type: 'array',
            data: minimum(),
            key: "id",
            immediate: true,
        }
    });
    var dataSourceIntermedian = ko.observable({
        store: {
            type: 'array',
            data: intermedian(),
            key: "id",
            immediate: true,
        }
    });
    var dataSourcePath = ko.observable({
        store: {
            type: 'array',
            data: path(),
            key: "id",
            immediate: true,
        }
    });

    var dataSource = {
        dataSourceItems: dataSourceItems,
        dataSourcePrices: dataSourcePrices,
        dataSourceMinimum: dataSourceMinimum,
        dataSourceIntermedian: dataSourceIntermedian,
        dataSourcePath: dataSourcePath,
        refresh: function() {
            dataSourceMinimum({
                store: {
                    type: 'array',
                    data: minimum(),
                    key: "id",
                    immediate: true,
                }
            });
            dataSourceIntermedian({
                store: {
                    type: 'array',
                    data: intermedian(),
                    key: "id",
                    immediate: true,
                }
            });
            dataSourcePath({
                store: {
                    type: 'array',
                    data: path(),
                    key: "id",
                    immediate: true,
                }
            });

            $('#dataGridItems').each(function(index, element) { $(element).dxDataGrid('instance').refresh(); });
            $('#dataGridPrices').each(function(index, element) { $(element).dxDataGrid('instance').refresh(); });
            $('#dataGridMinimum').each(function(index, element) { $(element).dxDataGrid('instance').refresh(); });
            $('#dataGridPath').each(function(index, element) { $(element).dxDataGrid('instance').refresh(); });
        },
        remove: function(key) {
            new DevExpress.data.DataSource(dataSourcePrices()).store()
                .remove(key)
                .done(function() {
                    // handle success
                    $('#dataGridPrices').each(function(index, element) { $(element).dxDataGrid('instance').refresh(); });
                })
                .fail(function(error) {
                    // handle error
                });
            new DevExpress.data.DataSource(dataSourceMinimum()).store()
                .remove(key)
                .done(function() {
                    // handle success
                    $('#dataGridMinimum').each(function(index, element) { $(element).dxDataGrid('instance').refresh(); });
                })
                .fail(function(error) {
                    // handle error
                });
            new DevExpress.data.DataSource(dataSourceIntermedian()).store()
                .remove(key)
                .done(function() {
                    // handle success
                })
                .fail(function(error) {
                    // handle error
                });
        },
        clear: function() {
            lastId(0);
            items([]);
            minimum([]);
            intermedian([]);
            path([]);
            new DevExpress.data.DataSource(dataSourceItems()).store().clear();
            new DevExpress.data.DataSource(dataSourcePrices()).store().clear();
            dataSource.refresh();
        }
    };

    var scrolling = {
        mode: 'virtual'
    };

    var priceSummary = ko.observable(0);
    var overlayVisible = ko.observable(false);

    var showOverlay = function(clickedCell) {
        if (window.console) console.log(clickedCell);

        if (!clickedCell.columnIndex) return;
        var arr = items();
        var i = clickedCell.data.id;
        var j = arr[clickedCell.columnIndex - 1].id;

        priceSummary(clickedCell.value);
        path([
            $.extend({
                price: 0
            }, Enumerable.From(items()).First(function(x) { return x.id == i; })),
            $.extend({
                price: clickedCell.value
            }, Enumerable.From(items()).First(function(x) { return x.id == j; }))
        ]);
        dataSource.refresh();

        overlayVisible(true);

        (function() {
            var arr = path();
            for (var run = true; run;) {
                run = false;
                for (var k = 0; k < arr.length - 1; k++) {
                    var a = arr[k];
                    var b = arr[k + 1];
                    if (Enumerable.From(intermedian()).Any(function(x) { return x.id == a.id && x["x" + b.id]; })) {
                        run = true;
                        var id = Enumerable.From(intermedian()).First(function(x) { return x.id == a.id; })["x" + b.id];
                        arr.splice(k + 1, 0, $.extend({
                            price: Enumerable.From(minimum()).First(function(x) { return x.id == a.id; })["x" + id]
                        }, Enumerable.From(items()).First(function(x) { return x.id == id; })));
                        arr[k + 2].price = parseFloat(arr[k + 2].price) - parseFloat(arr[k + 1].price);
                        path(arr);
                    };
                };
            };
        })();

        dataSource.refresh();
    };
    var hideOverlay = function() {
        overlayVisible(false);
    };

    var overlay = {
        priceSummary: priceSummary,
        overlayVisible: overlayVisible,
        showOverlay: showOverlay,
        hideOverlay: hideOverlay,
    };

    function onInsertOrUpdate(values, key) {
        lastId(Math.max(parseInt(key), parseInt(lastId())) + 1);
    };

    function onRemoved(key) {
        dataSource.remove(key);
    };

    var menuItems = [
        { text: "Floyd", icon: 'runner', clickAction: "View1" },
        { text: "About", icon: 'info', clickAction: "About" },
        { text: "Clear", clickAction: "View1/clear" }
    ];

    var viewModel = {
        message: message,

        lastId: lastId,
        itemsAsColumns: items,

        nextItemRowId: nextItemId,
        nextItemRowTitle: nextItemTitle,

        //  Put the binding properties here
        pivotItemSelectAction: function(e) {
            dataSource.refresh();
            if (typeof e.itemData.itemSelectAction != "undefined") {
                e.itemData.itemSelectAction(e);
            }
        },
        pivotItems: [
            {
                title: "Items",
                template: "items",
                columns: [
                    { caption: "ID", dataField: "id", dataType: "number" },
                    { caption: "Title", dataField: "title", dataType: "text" }
                ],
                dataSource: dataSourceItems,
                editing: {
                    editMode: 'batch',
                    editEnabled: true,
                    insertEnabled: true,
                    removeEnabled: true
                },
                scrolling: scrolling,
                itemSelectAction: function(e) {
                    message("Add items(points) before edit prices");
                    $("#toastContainer").dxToast('instance').show();
                    dataSource.refresh();
                },
            },
            {
                title: "Prices",
                template: "prices",
                columns: ko.computed(function() {
                    var arr = Enumerable.From(items()).Select(function(x) {
                        return $.extend({
                            allowEditing: true,
                        }, x);
                    }).ToArray();
                    arr.splice(0, 0, {
                        caption: "",
                        dataField: 'title',
                        dataType: "text",
                        allowEditing: false,
                    });
                    return arr;
                }),
                dataSource: dataSourcePrices,
                editing: {
                    editMode: 'batch',
                    editEnabled: true,
                    insertEnabled: false,
                    removeEnabled: false
                },
                scrolling: scrolling,
                itemSelectAction: function(e) {
                    message("Add prices from points to points");
                    $("#toastContainer").dxToast('instance').show();

                    new DevExpress.data.DataSource(dataSourceItems()).load()
                        .done(function(result) {
                            // 'result' contains the array associated with the DataSource
                            if (result.length) {
                                lastId(Enumerable.From(result).Select(function(x) { return parseInt(x.id); }).Max());
                                items(Enumerable.From(result).Select(function(x) {
                                    return $.extend({
                                        caption: x.title,
                                        dataField: 'x' + x.id,
                                        dataType: "text",
                                        format: 'decimal',
                                    }, x);
                                }).ToArray());
                            };
                            var store = new DevExpress.data.DataSource(dataSourcePrices()).store();
                            var count = 0;
                            $.each(result, function(index, element) {
                                store
                                    .insert(element)
                                    .done(function(values, key) {
                                        //'values' contains the inserted item values
                                        //'key' contains the inserted item key
                                        dataSource.refresh();
                                    })
                                    .fail(function(error) {
                                        //handle error
                                    });
                            });
                        });
                },
            },
            {
                title: "Minimum",
                template: "minimum",
                columns: ko.computed(function() {
                    var arr = Enumerable.From(items()).Select(function(x) {
                        return $.extend({
                            allowEditing: false,
                        }, x);
                    }).ToArray();
                    arr.splice(0, 0, {
                        caption: "",
                        dataField: 'title',
                        dataType: "text",
                        allowEditing: false,
                    });
                    return arr;
                }),
                dataSource: dataSourceMinimum,
                editing: {
                    editMode: 'batch',
                    editEnabled: false,
                    insertEnabled: false,
                    removeEnabled: false
                },
                scrolling: scrolling,
                itemSelectAction: function(e) {
                    message("Click a cell to view a path");
                    $("#toastContainer").dxToast('instance').show();
                    new DevExpress.data.DataSource(dataSourceItems()).load()
                        .done(function(result) {
                            // 'result' contains the array associated with the DataSource
                            if (result.length) {
                                lastId(Enumerable.From(result).Select(function(x) { return parseInt(x.id); }).Max());
                                items(Enumerable.From(result).Select(function(x) {
                                    return $.extend({
                                        caption: x.title,
                                        dataField: 'x' + x.id,
                                        dataType: "text",
                                        format: 'decimal',
                                        allowEditing: true,
                                    }, x);
                                }).ToArray());
                            };
                            new DevExpress.data.DataSource(dataSourcePrices()).load()
                                .done(function(result) {
                                    // 'result' contains the array associated with the DataSource                                   
                                    minimum(Enumerable.From(result).Select(function(x) { return x; }).ToArray());
                                    intermedian(Enumerable.From(result).Select(function(x) { return { id: x.id }; }).ToArray());

                                    var arr = minimum();
                                    var brr = intermedian();

                                    if (window.console) console.log(arr);
                                    if (window.console) console.log(brr);

                                    $.each(arr, function(index, element) {
                                        element['x' + element.id] = "";
                                    });

                                    minimum(arr);
                                    intermedian(brr);

                                    dataSource.refresh();

                                    (function() {
                                        // Floyd’s Algorithm
                                        for (var k = 0; k < arr.length; k++) {
                                            if (window.console) console.log("k = " + k);
                                            for (var i = 0; i < arr.length; i++) {
                                                for (var j = 0; j < arr.length; j++) {
                                                    if (i == j || i == k || k == j) continue;
                                                    var ij = arr[i] && typeof arr[i]['x' + arr[j].id] != "undefined" && arr[i]['x' + arr[j].id];
                                                    var ik = arr[i] && typeof arr[i]['x' + arr[k].id] != "undefined" && arr[i]['x' + arr[k].id];
                                                    var kj = arr[k] && typeof arr[k]['x' + arr[j].id] != "undefined" && arr[k]['x' + arr[j].id];
                                                    if (window.console) console.log("(" + arr[i].id + "," + arr[j].id + "," + arr[k].id + ")(" + ij + "," + ik + "," + kj + ")");
                                                    if (ij && ik && kj) {
                                                        var a = parseFloat(arr[i]['x' + arr[j].id]);
                                                        var b = parseFloat(arr[i]['x' + arr[k].id]) + parseFloat(arr[k]['x' + arr[j].id]);
                                                        if (a > b) {
                                                            arr[i]['x' + arr[j].id] = b;
                                                            brr[i]['x' + arr[j].id] = arr[k].id;
                                                            if (window.console) console.log(arr[i].id + "-" + arr[j].id + " <-> " + arr[i].id + "-" + arr[k].id + "," + arr[k].id + "-" + arr[j].id);
                                                        }
                                                    } else if (ik && kj) {
                                                        var b = parseFloat(arr[i]['x' + arr[k].id]) + parseFloat(arr[k]['x' + arr[j].id]);
                                                        arr[i]['x' + arr[j].id] = b;
                                                        brr[i]['x' + arr[j].id] = arr[k].id;
                                                        if (window.console) console.log(" + " + arr[i].id + "-" + arr[k].id + "," + arr[k].id + "-" + arr[j].id);
                                                    }
                                                };
                                            };
                                        };
                                    })();

                                    if (window.console) console.log(arr);
                                    if (window.console) console.log(brr);

                                    minimum(arr);
                                    intermedian(brr);

                                    dataSource.refresh();
                                });
                        });
                },
                cellClick: showOverlay,
            }
        ],

        // Overlay tab
        priceSummary: priceSummary,
        overlayVisible: overlayVisible,
        showOverlay: showOverlay,
        hideOverlay: hideOverlay,

        columns: [
            { caption: "ID", dataField: "id", dataType: "number" },
            { caption: "Title", dataField: "title", dataType: "text" },
            { caption: "Price", dataField: "price", dataType: "text", format: 'decimal' }
        ],
        dataSource: dataSourcePath,
        editing: {
            editMode: 'batch',
            editEnabled: false,
            insertEnabled: false,
            removeEnabled: false
        },
        scrolling: scrolling,

        viewShown: function() {
            $("#wrapper").height($(window).height() - $("#toolbar").height());
            if (params.id == "clear") {
                dataSource.clear();
                message("All data have been cleared");
                $("#toastContainer").dxToast('instance').show();
            };
            $(window).resize(function() {
                $("#wrapper").height($(window).height() - $("#toolbar").height());
            });
        },
        toolbarItems: [
            { location: 'center', text: 'Floyd' },
            {
                location: 'after',
                widget: 'dropDownMenu',
                options: {
                    items: menuItems,
                    itemClickAction: function(e) {
                        floyd.app.navigate(e.itemData.clickAction);
                    }
                }
            }
        ],
        slideoutItems: {
            items: menuItems,
            itemClickAction: function(e) {
                floyd.app.navigate(e.itemData.clickAction);
            }
        },
        menuItems: menuItems,
    };

    return viewModel;
};