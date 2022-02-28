// remote connection test
// remote connection test2
function selectAllCompanies() {
    $('#tt_grid').datagrid('selectAll');
}

function search_by_company() {
    $('#tt_grid').datagrid('load', {
        company: $('#company').val()
    });
}

function cellStyler(value, row, index) {
    if (value < 30) {
        return 'background-color:#ffee00;color:red;';
    }
}

function submitFormAuto() {
    console.warn($('#tt_grid_dynamic5').datagrid('getRows'));
    $.ajax({
        url: '../../../slim2_ecoman/index.php/insertIS',
        type: 'POST',
        dataType: 'json',
        data: 'row=' + JSON.stringify($('#tt_grid_dynamic5').datagrid('getRows')) + '&text=' + $('#tt_textAuto').textbox('getText'),
        success: function(data, textStatus, jqXHR) {
            console.warn('success text status-->' + textStatus);
            if (data["found"] == true) {
                $.messager.alert('Success', 'Success inserted IS Potential !', 'info');
                $('#saveWindowAuto').window('close');
                $('#tt_grid_dynamic5').datagrid('loadData', []);
            } else if (data["notFound"] == true) {
                $.messager.alert('Insert failed', 'Failed to insert IS Potential !', 'error');
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.warn('error text status-->' + textStatus);
        }
    });
}

function deleteAllISPotentialAuto() {
    $.messager.confirm('Confirm', 'Are you sure ? You will delete all rows...', function(r) {
        if (r) {
            $('#tt_grid_dynamic5').datagrid('loadData', []);
        }
    });
}

function getRowIndexAuto(target) {
    var tr = $(target).closest('tr.datagrid-row');
    return parseInt(tr.attr('datagrid-row-index'));
}

function deleteISPotentialAuto(target) {
    console.warn($('#tt_grid_dynamic5').datagrid('getSelections'));
    $.messager.confirm('Confirm', 'Are you sure? Selected row will be deleted...', function(r) {
        if (r) {
            $('#tt_grid_dynamic5').datagrid('deleteRow', getRowIndexAuto(target));
        }
    });
}

function addRowAuto() {
    var gridSelections = $('#tt_grid_dynamic').datagrid('getSelections');
    if (gridSelections.length > 0) {
        $.each(gridSelections, function(index, obj) {
            console.warn(obj);
            //$('#saveWindowAuto').window('open'); 
            $('#tt_grid_dynamic5').datagrid('appendRow', {
                id: '' + obj.id + '',
                company1: obj.company,
                qntty1: obj.qntty,
                company2: obj.tocompany,
                qntty2: obj.qntty2,
                flow: obj.flow,
                flowtype: 'floww type',
            });
        });
        $('#tt_grid_dynamic').datagrid('clearChecked');
    } else {
        $.messager.alert('Pick rows', 'Please select at least one row "Dynamic table with IS potentials" table', 'warning');
    }
}

function savePotentialsAuto() {
    if ($('#tt_grid_dynamic5').datagrid('getRows').length == 0) {
        $.messager.alert('Fill IS Potentials', 'Please fill IS Potentials table', 'warning');
    } else if ($('#tt_grid_dynamic5').datagrid('getRows').length > 0) {
        rowArray = $('#tt_grid_dynamic5').datagrid('getRows');
        $.each(rowArray, function(index, obj) {
            console.warn(obj);
            $('#saveWindowAuto').window('open');
        });
    }
}

function windowAutoISQuitWithoutSaving() {
    $.messager.confirm('Confirm', 'Are you sure ? You will close window without saving...', function(r) {
        if (r) {
            $('#saveWindowAuto').window('close');
        }
    });
}

function saveAutoPotentials() {
    if ($('#tt_grid_dynamic5').datagrid('getRows').length == 0) {
        $.messager.alert('Select row', 'Select at least one IS Potental row', 'warning');
    } else if ($('#tt_grid_dynamic5').datagrid('getRows').length > 0) {
        rowArray = $('#tt_grid_dynamic5').datagrid('getRows');
        $.each(rowArray, function(index, obj) {
            console.warn(obj);
            $('#saveWindowAuto').window('open');
        });
    }
}

function deleteAllAutoPotential() {
    $.messager.confirm('Confirm', 'Are you sure ? You will delete all rows...', function(r) {
        if (r) {
            $('#tt_grid_dynamic').datagrid('loadData', []);
        }
    });
}

function getColumnsDynamic() {
    console.warn($("#tt_tree").tree("getChecked"));
    var checkedArray = Array("");
    checkedArray = $("#tt_tree").tree("getChecked");
    var columnArray = [];
    columnArray.push({
        field: 'ck',
        title: 'From Company',
        width: 200,
        checkbox: true
    });
    columnArray.push({
        field: 'company',
        title: 'From Company',
        width: 100
    });
    columnArray.push({
        field: 'flow',
        title: 'Flow',
        width: 100
    });
    columnArray.push({
        field: 'qntty',
        title: 'Quantity',
        width: 100
    });
    columnArray.push({
        field: 'qnttyunit',
        title: 'Unit',
        width: 100
    });
    columnArray.push({
        field: 'fromflowtype',
        title: 'Flow Type',
        width: 100
    });
    columnArray.push({
        field: 'tocompany',
        title: ' To Company',
        width: 200
    });
    columnArray.push({
        field: 'qntty2',
        title: 'Quantity',
        width: 100
    });
    columnArray.push({
        field: 'qntty2unit',
        title: 'Unit',
        width: 100
    });
    columnArray.push({
        field: 'toflowtype',
        title: 'Flow Type',
        width: 100
    });
    $.each(checkedArray, function(index, obj) {
        if (obj.attributes.notroot) {}
    });
    $('#tt_grid_dynamic').datagrid({
        columns: [
            columnArray
        ],
    });
}

function getCompaniesISPotentials() {
    checkedArray = $("#tt_tree").tree("getChecked");
    gridCheckedArray = $("#tt_grid").datagrid("getSelections");
    console.warn(checkedArray.length);
    console.warn(gridCheckedArray.length);
    if (gridCheckedArray.length == 0 && checkedArray.length == 0) {
        $.messager.alert('Pick flow and company ', 'Please select sub flow and company !', 'warning');
    } else if (gridCheckedArray.length == 0) {
        $.messager.alert('Pick flow ', 'Please select  company !', 'warning');
    } else if (checkedArray.length == 0) {
        $.messager.alert('Pick flow ', 'Please select sub flow!', 'warning');
    } else if (checkedArray.length > 0 && gridCheckedArray.length > 0) {
        var flowStr = "";
        var companyStr = "";
        $.each(checkedArray, function(index, obj) {
            if (obj.attributes.notroot) {
                flowStr += obj.id + ',';
            }
        });
        $.each(gridCheckedArray, function(index, obj) {
            console.warn(obj);
            companyStr += obj.id + ',';
        });
        /**
         *  @todo buras� dinamik kolon yap�s� i�in denenecek
         */
        $.ajax({
            url: '../../../Proxy/SlimProxy.php',
            data: {
                //url : 'ISPotentialsNew_json_test',
                url: 'ISPotentialsNew_json_test_by_project',
                selectedFlows: flowStr,
                companies: companyStr,
                IS: $('#IS_search').combobox('getValue'),
                prjId: $('#IS_project').combobox('getValue')
            },
            type: 'GET',
            dataType: 'json',
            success: function(data, textStatus, jqXHR) {
                if (!data['notFound']) {
                    $('#tt_grid_dynamic').datagrid('loadData', data);
                    $('#tt_grid_dynamic').datagrid({});
                } else {
                    console.warn('data notfound-->' + textStatus);
                    $.messager.alert('Pick sub flow and company', 'Please select  a sub flow from flow tree!', 'warning');
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.warn('error text status-->' + textStatus);
            }
        });
    }
}

function beginISPotential() {
    $('#tt_grid_dynamic5').datagrid('loadData', []);
    $('#tt_grid_dynamic5').datagrid('loading');
    $('#tt_grid_dynamic5').datagrid('getPanel').panel('setTitle', 'Companies by specific flow');
    if ($('#tt_grid').datagrid('getSelections').length == 1) {} else if ($('#tt_grid').datagrid('getSelections').length > 1) {
        getCompaniesISPotentials($('#tt_grid2').datagrid('getSelections')[0].id, $('#tt_grid2').datagrid('getSelections')[0].company);
    } else {
        $.messager.alert('Pick a company', 'Please select  company!', 'warning');
    }
}

function getTreeRoots() {
    var treeRoots = $('#tt_tree').tree("getRoots");
    $.each(treeRoots, function(index, obj) {
        obj.checked = true;
    });
}
$(function() {
    var treeValue;
    $("#tt_tree").tree({
        onCheck: function(node, checked) {
            if (checked) {
                if (node.attributes.notroot) {
                    $('#tt_grid').datagrid("hideColumn", node.text);
                    $('#tt_grid').datagrid("showColumn", node.text);
                    console.error($('#tt_grid').datagrid('getColumnFields'));
                }
                if (node.children) {
                    $.each(node.children, function(index, obj) {
                        $('#tt_grid').datagrid("hideColumn", obj.text);
                        $('#tt_grid').datagrid("showColumn", obj.text);
                    });
                }
            } else {
                if (node.attributes.notroot) {
                    $('#tt_grid').datagrid("hideColumn", node.text);
                }
                if (node.children) {
                    $.each(node.children, function(index, obj) {
                        $('#tt_grid').datagrid("hideColumn", obj.text);
                    });
                }
            }
        },
        onClick: function(node) {
            var parentnode = $("#tt_tree").tree("getParent", node.target);
            var roots = $("#tt_tree").tree("getRoots");
            var treeValue;
            if (node.state == undefined) {
                var de = parentnode.text;
                var test_array = de.split("/");
                treeValue = test_array[1];
            } else {
                treeValue = parentnode.text;
            }
            var imagepath = parentnode.text + "/" + node.text;
        },
        onExpand: function(node) {
            var root = $("#tt_tree").tree("getRoot");
            var parent = $("#tt_tree").tree("getParent", node.target);
            if (parent) {
                var nodes = $('#tt_tree').tree('getChecked');
                var s = '';
                var num = '';
                for (var i = 0; i < nodes.length; i++) {
                    if (s != '') s += ',';
                    s += nodes[i].text;
                    if (num != '') num += ',';
                    num += nodes[i].id;
                }
            } else {
                treeValue = node.text;
                var nodeId = node.id;
            }
        },
        onCollapse: function(node) {
            var root = $("#tt_tree").tree("getRoot");
            var parent = $("#tt_tree").tree("getParent", node.target);
            if (parent) {} else {
                var nodeId = node.id;
                var selections = $('#tt_grid').datagrid("getSelections");
                for (var i = 0; i < selections.length; i++) {}
            }
        },
        onDblClick: function(node) {
            var deneme = "test";
            var parent = $("#tt_tree").tree("getParent", node.target);
            if (parent) {} else {}
        }
    });
    $('#tt_tree').tree({
        url: '../../../Proxy/SlimProxy.php',
        queryParams: {
            url: 'flows'
        },
        method: 'get',
        animate: true,
        checkbox: true
    });
    $('#tt_grid_dynamic').datagrid({
        singleSelect: false,
        collapsible: true,
        method: 'get',
        idField: 'id',
        toolbar: '#tb5',
        remoteSort: false,
        multiSort: false,
        fit: true,
        fitColumns: true,
    });
    $.ajax({
        url: '../../../Proxy/SlimProxy.php',
        data: {
            url: 'columnflows_json_test'
        },
        type: 'GET',
        dataType: 'json',
        success: function(data, textStatus, jqXHR) {
            console.warn('success text status-->' + textStatus);
            $('#tt_grid').datagrid({
                collapsible: true,
                url: '../../../Proxy/SlimProxy.php',
                queryParams: {
                    url: 'companies_json_test2'
                },
                method: 'get',
                idField: 'id',
                toolbar: '#tb',
                remoteSort: true,
                multiSort: false,
                loadMsg: 'Please wait while loading...',
                rownumbers: "true",
                pagination: "true",
                remoteFilter: true,
                columns: [
                    data
                ],
                onDblClickRow: function(rowIndex, rowData) {}
            });
            var gridColumns = $('#tt_grid').datagrid('getColumnFields');
            var arrayFilter = [];
            var arrayFirst = [];
            $.each(gridColumns, function(index, obj) {
                arrayFirst = [];
                if (obj.toLowerCase() == 'company') {
                    return true;
                }
                arrayFirst = {
                    field: obj,
                    type: 'numberbox',
                    options: {
                        precision: 1
                    },
                    op: ['equal', 'notequal', 'less', 'greater']
                };
                arrayFilter.push(arrayFirst);
            });
            var dg = $('#tt_grid').datagrid();
            dg.datagrid('enableFilter', arrayFilter);
            $('#tt_grid_scenarios').datagrid({
                collapsible: true,
                url: '../../../Proxy/SlimProxy.php',
                queryParams: {
                    url: 'ISScenarios'
                },
                method: 'get',
                idField: 'id',
                remoteSort: false,
                multiSort: false,
                rownumbers: "true",
                pagination: "true",
                fit: true,
                pagePosition: "top",
                columns: [
                    [{
                        field: 'prj_name',
                        title: 'Project Name',
                        width: 300
                    }, {
                        field: 'syn_name',
                        title: 'Synergy Type',
                        width: 300
                    }, {
                        field: 'date',
                        title: ' Project Date',
                        width: 300
                    }, {
                        field: 'detail',
                        title: ' Details',
                        width: 100
                    }]
                ]
            });
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.warn('error text status-->' + textStatus);
        }
    });
    $('#tt_grid_dynamic5').datagrid({
        columns: [
            [{
                field: 'company1',
                title: 'Company',
                width: 100
            }, {
                field: 'qntty1',
                title: 'Quantity',
                width: 100
            }, {
                field: 'company2',
                title: 'Company',
                width: 100
            }, {
                field: 'qntty2',
                title: 'Quantity',
                width: 100
            }, {
                field: 'flow',
                title: 'Flow',
                width: 100
            }, {
                field: 'flowtype',
                title: 'I/O',
                width: 100
            }, {
                field: 'action',
                title: 'Action',
                width: 150,
                align: 'center',
                formatter: function(value, row, index) {
                    if (row.editing) {
                        var s = '<a href="#" onclick="saverow(this)">Save</a> ';
                        var c = '<a href="#" onclick="cancelrow(this)">Cancel</a>';
                        return s + c;
                    } else {
                        var d = '<button class="btn btn-mini rn_btnDelete" onclick="deleteISPotentialAuto(this)">Delete</button>';
                        return d;
                    }
                }
            }, {
                field: 'map',
                title: 'Map',
                width: 150,
                align: 'center',
                formatter: function(value, row, index) {
                    if (row.editing) {
                        var s = '<a href="#" onclick="saverow(this)">Save</a> ';
                        var c = '<a href="#" onclick="cancelrow(this)">Cancel</a>';
                        return s + c;
                    } else {
                        //var e = '<a href="#" onclick="editrow(this)">Edit</a> ';
                        //var d = '<a href="#" onclick="deleteISPotential(this)" >Delete</a>';
                        console.log('row satır id bilgileri' + row.id);
                        var arrSplit = row.id.split(",");
                        var d = '<button class="btn btn-mini rn_btnDelete" onclick="window.open(\'../IS_OpenLayers/map.php?to_company=' + arrSplit[1] + '&from_company=' + arrSplit[0] + '\',\'mywindow\',\'width=900,height=900\')">See on Map</button>';
                        //return e+d;
                        return d;
                    }
                }
            }]
        ],
        idField: 'id',
        singleSelect: true,
        collapsible: true,
        fitColumns: true,
        toolbar: '#tb6',
        onDblClickRow: function(rowIndex, rowData) {
            console.warn(rowData);
        }
    });
    $('#printTest').click(function() {
        $.print("#zeyn");
    });
    $('#printGrid').click(function() {
        $.print("#tt_grid_div");
    });
    $('#printGridPotentials').click(function() {
        $.print("#tt_grid_dynamic5_div");
    });
});