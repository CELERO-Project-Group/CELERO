function closeMapPanel() {
    //var panelWest = $('#cc').layout('panel','south');
    //var panelSouthNorth = $('#cc2').layout('panel','north');
    $('#p').panel('collapse');
}

function showMapPanelExpand() {
    //var panelWest = $('#cc').layout('panel','south');
    //var panelSouthNorth = $('#cc2').layout('panel','north');
    $('#p').panel('expand');
}

//IS Scenario Details button, show the flows in tt_grid_scenarios_details (the same as double click an a row)
function showScnDetailsButton(target) {
    var row = $('#tt_grid_scenarios').datagrid('getSelected');
    $('#tt_scenario_name').textbox('setText', row.prj_name);
    $('#tt_grid_scenarios_details').datagrid({
        url: '../../../Proxy/SlimProxy.php',
        queryParams: {
            url: 'getScenarioDetails_scn',
            id: row.id
        },
    });
}

function deleteISScenario(target) {
    //console.warn($('#tt_grid_dynamic5').datagrid('getSelections'));
    $.messager.confirm('Confirm', 'Are you sure? Selected row will be deleted...', function(r) {
        if (r) {
            var rows = $('#tt_grid_scenarios').datagrid('getRows');
            var tr = $(target).closest('tr.datagrid-row');
            var rowIndex = parseInt(tr.attr('datagrid-row-index'));
            var row = rows[rowIndex];
            console.log(row);
            $.ajax({
                url: '../../../Proxy/SlimProxy.php',
                data: {
                    url: 'deleteScenario_scn',
                    id: row.id
                },
                type: 'GET',
                dataType: 'json',
                success: function(data, textStatus, jqXHR) {
                    $('#tt_grid_scenarios').datagrid('reload');
                    if (!data['notFound']) {} else {
                        /*console.warn('data notfound-->'+textStatus);
                        $.messager.alert('Pick sub flow and company','Please select  a sub flow from flow tree!','warning');*/
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.warn('error text status-->' + textStatus);
                }
            });
        }
    });
}

function updateActions(index) {
    //console.log(index);
    console.log('updateActions');
    var row = $('#tt_grid_scenarios').datagrid('getSelected');
    /*console.log('updateActions');
    console.log(row);*/
    $('#tt_grid_scenarios').datagrid('updateRow', {
        index: index,
        row: {}
    });
}

function getRowIndex(target) {
    var tr = $(target).closest('tr.datagrid-row');
    return parseInt(tr.attr('datagrid-row-index'));
}

function editrow(target) {
    console.log('editrow');
    console.log(target);
    var rows = $('#tt_grid_scenarios').datagrid('getRows');
    var row = rows[getRowIndex(target)];
    console.log(row);
    //$('#tt').datagrid('selectRow',getRowIndex(target));
    $('#tt_grid_scenarios').datagrid('beginEdit', getRowIndex(target));
}

function deleterow(target) {
    /*$.messager.confirm('Confirm','Are you sure?',function(r){
            if (r){
                    $('#tt_grid_scenarios').datagrid('deleteRow', getRowIndex(target));
            }
    });*/
    $.messager.confirm('Confirm', 'Are you sure? Selected row will be deleted...', function(r) {
        if (r) {
            var rows = $('#tt_grid_scenarios').datagrid('getRows');
            var tr = $(target).closest('tr.datagrid-row');
            var rowIndex = parseInt(tr.attr('datagrid-row-index'));
            var row = rows[rowIndex];
            console.log(row);
            $.ajax({
                url: '../../../Proxy/SlimProxy.php',
                data: {
                    url: 'deleteScenario_scn',
                    id: row.id
                },
                type: 'GET',
                dataType: 'json',
                success: function(data, textStatus, jqXHR) {
                    $('#tt_grid_scenarios').datagrid('reload');
                    if (!data['notFound']) {} else {
                        /*console.warn('data notfound-->'+textStatus);
                        $.messager.alert('Pick sub flow and company','Please select  a sub flow from flow tree!','warning');*/
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.warn('error text status-->' + textStatus);
                }
            });
        }
    });
}

function saverow(target) {
    $('#tt_grid_scenarios').datagrid('endEdit', getRowIndex(target));
    var rows = $('#tt_grid_scenarios').datagrid('getRows');
    var row = rows[getRowIndex(target)];
    console.log(row);
    //console.error(getRowIndex(target));
}

function cancelrow(target) {
    $('#tt_grid_scenarios').datagrid('cancelEdit', getRowIndex(target));
}

function insert() {
    var row = $('#tt_grid_scenarios').datagrid('getSelected');
    if (row) {
        var index = $('#tt_grid_scenarios').datagrid('getRowIndex', row);
    } else {
        index = 0;
    }
    /*$('#tt_grid_scenarios').datagrid('insertRow', {
            index: index,
            row:{
                    status:'P'
            }
    });*/
    $('#tt_grid_scenarios').datagrid('selectRow', index);
    $('#tt_grid_scenarios').datagrid('beginEdit', index);
}

function updateActionsCmpnyFlow(index) {
    //console.log(index);
    console.log('updateActionsCmpnyFlow');
    var row = $('#tt_grid_scenarios_details_edit').datagrid('getSelected');
    /*console.log('updateActions');
    console.log(row);*/
    $('#tt_grid_scenarios_details_edit').datagrid('updateRow', {
        index: index,
        row: {}
    });
}

function editrowCmpnyFlow(target) {
    console.log('editrowCmpnyFlow');
    console.log(target);
    var rows = $('#tt_grid_scenarios_details_edit').datagrid('getRows');
    var row = rows[getRowIndex(target)];
    console.log(row);
    //$('#tt').datagrid('selectRow',getRowIndex(target));
    $('#tt_grid_scenarios_details_edit').datagrid('beginEdit', getRowIndex(target));
}

function saverowCmpnyFlow(target) {
    $('#tt_grid_scenarios_details_edit').datagrid('endEdit', getRowIndex(target));
    var rows = $('#tt_grid_scenarios_details_edit').datagrid('getRows');
    var row = rows[getRowIndex(target)];
    console.log(row);
    //console.error(getRowIndex(target));
}

function cancelrowCmpnyFlow(target) {
    $('#tt_grid_scenarios_details_edit').datagrid('cancelEdit', getRowIndex(target));
}
$(function() {
    $('#tt_grid_scenarios').datagrid({
        toolbar: '#tb',
        collapsible: true,
        url: '../../../Proxy/SlimProxy.php',
        queryParams: {
            url: 'ISScenariosCns_scn',
            consultant_id: parseInt(document.getElementById('consultant_id').value),
            prj_id: parseInt(document.getElementById('prj_id').value)
        },
        method: 'get',
        idField: 'id',
        remoteSort: false,
        multiSort: false,
        rownumbers: "true",
        pagination: true,
        fit: true,
        pagePosition: "bottom",
        columns: [
            [{
                    field: 'prj_name',
                    title: 'IS Table Name',
                    width: 100,
                    editor: 'text'
                },
                /*{field:'prj_name',title:'IS Table Name',width:300,editor:{
                    type:'text',
                    options:{
                        required:true
                    }}
                    },*/
                {
                    field: 'syn_name',
                    title: 'Synergy Type',
                    width: 150
                }, {
                    field: 'status',
                    title: 'Status',
                    width: 100
                }, {
                    field: 'date',
                    title: ' Project Date',
                    width: 150
                }, {
                    field: 'detail',
                    title: ' Details',
                    width: 100
                }, {
                    field: 'action',
                    title: 'Action',
                    width: 80,
                    align: 'center',
                    formatter: function(value, row, index) {
                        if (row.editing) {
                            var s = '<a href="javascript:void(0)" onclick="saverow(this)">Save</a> ';
                            var c = '<a href="javascript:void(0)" onclick="cancelrow(this)">Cancel</a>';
                            return s + c;
                        } else {
                            var e = '<a href="javascript:void(0)" onclick="editrow(this)">Edit</a> ';
                            //var d = '<a href="javascript:void(0)" onclick="deleteISScenario(this);">Delete</a>';
                            var d = '<a href="javascript:void(0)" onclick="deleterow(this);">Delete</a>';
                            return e + d;
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
                            console.log(row);
                            //var x = '<button onclick="document.getElementById(\'myFrame\').setAttribute(\'src\',\'../IS_OpenLayers/map.php?to_company='+arrSplit[1]+'&from_company='+arrSplit[0]+'&prj_id='+document.getElementById('prj_id').value+'\')"> See on Map</button>';
                            var x = '<a href="#add" class="easyui-linkbutton" iconCls="icon-save" onclick="showMapPanelExpand();document.getElementById(\'myFrame\').setAttribute(\'src\',\'../IS_OpenLayers/map_prj.php?prj_id=' + row.id + '\')"> See on Map</a>';
                            //return e+d;
                            return x;
                        }
                    }
                }
            ]
        ],
        onBeforeEdit: function(index, row) {
            row.editing = true;
            updateActions(index);
        },
        onAfterEdit: function(index, row) {
            console.log(row);
            console.log('onAfterEdit');
            if (row.prj_name == '') {
                $.messager.alert('Warning', 'Fill Scenario Name!', 'warning');
            } else {
                row.editing = false;
                $.messager.confirm('Confirm', 'Are you sure? Scenario name will be updated...', function(r) {
                    if (r) {
                        console.log(row);
                        $.ajax({
                            url: '../../../Proxy/SlimProxy.php',
                            data: {
                                url: 'updateScenario_scn',
                                id: row.id,
                                scenario: row.prj_name
                            },
                            type: 'GET',
                            dataType: 'json',
                            success: function(data, textStatus, jqXHR) {
                                if (!data['notFound']) {
                                    if (data['id'] > 0) $.messager.alert('Scenario Updated', 'Updated succesfully!', 'info');
                                    //if(data['id']==0) $.messager.alert('Scenario Updated','Updated succesfully!','info');
                                } else {
                                    $.messager.alert('Update Failure', 'Update failure!', 'error');
                                    /*console.warn('data notfound-->'+textStatus);
                                    $.messager.alert('Pick sub flow and company','Please select  a sub flow from flow tree!','warning');*/
                                }
                                $('#tt_grid_scenarios').datagrid('reload');
                            },
                            error: function(jqXHR, textStatus, errorThrown) {
                                console.warn('error text status-->' + textStatus);
                                $.messager.alert('Update Failure', 'Update failure!', 'error');
                            }
                        });
                    }
                });
                //updateActions(index);
            }
        },
        onCancelEdit: function(index, row) {
            console.log('onCancelEdit');
            row.editing = false;
            updateActions(index);
        },
        singleSelect: false,
        multiSelect: false,
        onDblClickRow: function(rowIndex, rowData) {
            $('#tt_scenario_name').textbox('setText', rowData.prj_name);
            $('#tt_grid_scenarios_details').datagrid({
                url: '../../../Proxy/SlimProxy.php',
                queryParams: {
                    url: 'getScenarioDetails_scn',
                    id: rowData.id
                },
            });
        },
        //closed:true,
        //minimized:true,
    });
    $('#tt_grid_scenarios_details').datagrid({
        singleSelect: true,
        url: '../../../Proxy/SlimProxy.php',
        queryParams: {
            url: 'getScenarioDetailsCns_scn',
            consultant_id: document.getElementById('consultant_id').value,
            id: parseInt(document.getElementById('prj_id').value)
        },
        collapsible: true,
        method: 'get',
        idField: 'id',
        toolbar: '#tb_scenario_details',
        remoteSort: false,
        multiSort: false,
        columns: [
            [
                //{field:'sirket_id',title:'ID',width:300},
                //{field: 'ck',title: 'From Company',checkbox:true},
                //{field: 'IS Scenario',title: 'IS Scenario'},
                {
                    field: 'company',
                    title: 'From Company'
                }, {
                    field: 'flow',
                    title: 'Flow'
                }, {
                    field: 'qntty',
                    title: 'Quantity'
                }, {
                    field: 'qnttyunit',
                    title: 'Unit'
                }, {
                    field: 'fromflowtype',
                    title: 'Flow Type'
                }, {
                    field: 'tocompany',
                    title: ' To Company'
                }, {
                    field: 'flowto',
                    title: 'Flow'
                }, {
                    field: 'qntty2',
                    title: 'Quantity'
                }, {
                    field: 'qntty2unit',
                    title: 'Unit'
                }, {
                    field: 'toflowtype',
                    title: 'Flow Type'
                },
            ]
        ],
        fit: true,
        fitColumns: true,
        onDblClickRow: function(rowIndex, rowData) {
            //console.error(rowData);
            var strReq = rowData.id;
            var splitArr = strReq.split(",");
            var regArr = {
                'from': splitArr[0],
                'to': splitArr[1],
                'flow': splitArr[2]
            };
            $('#tt_grid_scenarios_details_edit').datagrid({
                url: '../../../Proxy/SlimProxy.php',
                queryParams: {
                    url: 'getFlowDetails_prj',
                    items: JSON.stringify(regArr),
                },
            });
        },
    });
    var products = [{
        id: 'FI-SW-01',
        name: ''
    }, {
        id: 'K9-DL-01',
        name: 'Dalmation'
    }, {
        id: 'RP-SN-01',
        name: 'Rattlesnake'
    }, {
        id: 'RP-LI-02',
        name: 'Iguana'
    }, {
        id: 'FL-DSH-01',
        name: 'Manx'
    }, {
        id: 'FL-DLH-02',
        name: 'Persian'
    }, {
        id: 'AV-CB-01',
        name: 'Amazon Parrot'
    }];
    console.log(products);
    var units = [{
        id: "1",
        name: ""
    }, {
        id: "2",
        name: "%"
    }, {
        id: "3",
        name: "1/seconed"
    }, {
        id: "4",
        name: "Amper"
    }, {
        id: "5",
        name: "bar"
    }, {
        id: "6",
        name: "degree"
    }, {
        id: "7",
        name: "dk"
    }, {
        id: "8",
        name: "gram"
    }, {
        id: "9",
        name: "kg"
    }, {
        id: "10",
        name: "KW"
    }, {
        id: "11",
        name: "Liter"
    }, {
        id: "12",
        name: "M"
    }, {
        id: "13",
        name: "m/dk"
    }, {
        id: "14",
        name: "m/min"
    }, {
        id: "15",
        name: "m/s"
    }, {
        id: "16",
        name: "m³/min"
    }, {
        id: "17",
        name: "micrometer"
    }, {
        id: "18",
        name: "mm"
    }, {
        id: "19",
        name: "m²"
    }, {
        id: "20",
        name: "m³"
    }, {
        id: "21",
        name: "mm/s"
    }, {
        id: "22",
        name: "N*m"
    }, {
        id: "23",
        name: "Newton"
    }, {
        id: "24",
        name: "Nm"
    }, {
        id: "25",
        name: "number/pocket"
    }, {
        id: "26",
        name: "Pa"
    }, {
        id: "27",
        name: "Pa/min"
    }, {
        id: "28",
        name: "pocket"
    }, {
        id: "29",
        name: "quantity"
    }, {
        id: "30",
        name: "rpm"
    }, {
        id: "31",
        name: "steps"
    }, {
        id: "32",
        name: "unit"
    }, {
        id: "33",
        name: "unit/min"
    }, {
        id: "34",
        name: "volt"
    }, {
        id: "35",
        name: "volt,Watt"
    }, {
        id: "36",
        name: "year"
    }, {
        id: "37",
        name: "kWh "
    }, {
        id: "38",
        name: "hours/year"
    }, {
        id: "39",
        name: "month(s)"
    }, {
        id: "40",
        name: "week(s)"
    }];
    var transport = [];
    var state = [{
        id: "1",
        name: "Solid"
    }, {
        id: "2",
        name: "Liquid"
    }, {
        id: "3",
        name: "Gas"
    }, ];
    $('#tt_grid_scenarios_details_edit').datagrid({
        //url:'../../../Proxy/SlimProxy.php',
        //queryParams : { url:'getFlowDetails_prj',},
        //fitColumns:true,
        singleSelect: false,
        multiSelect: false,
        rownumbers: true,
        //loadMsg:'',
        height: 'auto',
        columns: [
            [{
                field: 'company',
                title: 'Company',
                width: 100
            }, {
                field: 'potential_energy',
                title: 'Potential Energy',
                width: 100,
                editor: {
                    type: 'numberbox',
                    options: {
                        precision: 2
                    }
                }
            }, {
                field: 'potential_energy_unit',
                title: 'Potential Energy Unit',
                width: 100,
                formatter: function(value) {
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].id == value) return units[i].name;
                    }
                    return value;
                },
                editor: {
                    type: 'combobox',
                    options: {
                        valueField: 'id',
                        textField: 'name',
                        data: units,
                        required: false
                    }
                }
            }, {
                field: 'supply_cost',
                title: 'Supply Cost',
                width: 100,
                editor: {
                    type: 'numberbox',
                    options: {
                        precision: 2
                    }
                }
            }, {
                field: 'supply_cost_unit',
                title: 'Supply Cost Unit',
                width: 100,
                formatter: function(value) {
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].id == value) return units[i].name;
                    }
                    return value;
                },
                editor: {
                    type: 'combobox',
                    options: {
                        valueField: 'id',
                        textField: 'name',
                        data: units,
                        required: false
                    }
                }
            }, {
                field: 'transport_id',
                title: 'Transport',
                width: 100,
                formatter: function(value) {
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].id == value) return units[i].name;
                    }
                    return value;
                },
                editor: {
                    type: 'combobox',
                    options: {
                        valueField: 'id',
                        textField: 'name',
                        data: transport,
                        required: false
                    }
                }
            }, {
                field: 'entry_date',
                title: 'Entry Date',
                width: 100
            }, {
                field: 'concentration',
                title: 'Concentration',
                width: 100,
                editor: {
                    type: 'numberbox'
                }
            }, {
                field: 'pression',
                title: 'Press.',
                width: 100,
                editor: {
                    type: 'numberbox'
                }
            }, {
                field: 'state_id',
                title: 'State',
                width: 100,
                formatter: function(value) {
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].id == value) return units[i].name;
                    }
                    return value;
                },
                editor: {
                    type: 'combobox',
                    options: {
                        valueField: 'id',
                        textField: 'name',
                        data: state,
                        required: false
                    }
                }
            }, {
                field: 'min_flow_rate',
                title: 'Min Flow Rate',
                width: 100,
                editor: {
                    type: 'numberbox',
                    options: {
                        precision: 2
                    }
                }
            }, {
                field: 'min_flow_rate_unit',
                title: 'Min Flow Rate Unit',
                width: 100,
                formatter: function(value) {
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].id == value) return units[i].name;
                    }
                    return value;
                },
                editor: {
                    type: 'combobox',
                    options: {
                        valueField: 'id',
                        textField: 'name',
                        data: units,
                        required: false
                    }
                }
            }, {
                field: 'max_flow_rate',
                title: 'Max Flow Rate',
                width: 100,
                editor: {
                    type: 'numberbox',
                    options: {
                        precision: 2
                    }
                }
            }, {
                field: 'max_flow_rate_unit',
                title: 'Max Flow Rate Unit',
                width: 100,
                formatter: function(value) {
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].id == value) return units[i].name;
                    }
                    return value;
                },
                editor: {
                    type: 'combobox',
                    options: {
                        valueField: 'id',
                        textField: 'name',
                        data: units,
                        required: false
                    }
                }
            }, {
                field: 'qntty',
                title: 'Quantity',
                width: 100,
                editor: {
                    type: 'numberbox',
                    options: {
                        precision: 2
                    }
                }
            }, {
                field: 'qntty_unit_id',
                title: 'Quantity Unit',
                width: 100,
                formatter: function(value) {
                    for (var i = 0; i < units.length; i++) {
                        if (units[i].id == value) return units[i].name;
                    }
                    return value;
                },
                editor: {
                    type: 'combobox',
                    options: {
                        valueField: 'id',
                        textField: 'name',
                        data: units,
                        required: false
                    }
                }
            }, {
                field: 'substitute_potential',
                title: 'Substitute Potential',
                width: 100,
                editor: 'text'
            }, {
                field: 'quality',
                title: 'Quality',
                width: 100,
                editor: 'text'
            }, {
                field: 'ep_unit_id',
                title: 'Ep Unit',
                width: 100,
                editor: 'text'
            }, {
                field: 'comment',
                title: 'Comment',
                width: 100,
                editor: 'text'
            }, {
                field: 'description',
                title: 'Description',
                width: 100,
                editor: 'text'
            }, {
                field: 'action',
                title: 'Action',
                width: 80,
                align: 'center',
                formatter: function(value, row, index) {
                    if (row.editing) {
                        var s = '<a href="javascript:void(0)" onclick="saverowCmpnyFlow(this)">Save</a> ';
                        var c = '<a href="javascript:void(0)" onclick="cancelrowCmpnyFlow(this)">Cancel</a>';
                        return s + c;
                        //return s;
                    } else {
                        var e = '<a href="javascript:void(0)" onclick="editrowCmpnyFlow(this)">Edit</a> ';
                        //var d = '<a href="javascript:void(0)" onclick="deleteISScenario(this);">Delete</a>';
                        //var d = '<a href="javascript:void(0)" onclick="deleterowCmpnyFlow(this);">Delete</a>';
                        //return e+d;
                        return e;
                    }
                }
            }, {
                field: 'link',
                title: 'Link',
                width: 80,
                align: 'center',
                formatter: function(value, row, index) {
                    //var link = '<a href="new_flow/'+row.id+'" onclick="" class="easyui-linkbutton" iconCls="icon-back" plain="true">Dataset Management</a>';
                    var link = '<a href="#" onclick="event.preventDefault();window.open(\'new_flow/' + row.id + '\', \'_blank\');" class="easyui-linkbutton" iconCls="icon-back" plain="true">Dataset Management</a>';
                    return link
                }
            }]
        ],
        onBeforeLoad: function() {
            /*$.ajax({
                url: '../../../Proxy/SlimProxy.php',
                data : {
                        url : 'getUnitsAll_scn',
                },
                type: 'POST',
                dataType : 'json',
                success: function(data, textStatus, jqXHR) {
                  console.warn('success text status-->'+textStatus);
                  console.warn(data);
                  //units = data;
                  //console.warn(units);
                  //var arr = $.map(data, function (value, key) { return value; });
                  //console.log(arr);
                  $.each(data, function( index, value ) {
                        console.log(value);
                        //units.push(value);
                      });
                  console.log(units);
                },
                error: function(jqXHR , textStatus, errorThrown) {
                  console.warn('error text status-->'+textStatus);
                }
            });*/
        },
        onBeforeEdit: function(index, row) {
            row.editing = true;
            updateActionsCmpnyFlow(index);
        },
        onAfterEdit: function(index, row) {
            console.log(row);
            console.log('onAfterEdit');
            if (row.prj_name == '') {
                $.messager.alert('Warning', 'Fill Scenario Name!', 'warning');
            } else {
                row.editing = false;
                $.messager.confirm('Confirm', 'Are you sure? Company Flow data will be updated...', function(r) {
                    if (r) {
                        console.log(row);
                        $.ajax({
                            url: '../../../Proxy/SlimProxy.php',
                            data: {
                                url: 'updateScenario_scn',
                                id: row.id,
                                scenario: row.prj_name
                            },
                            type: 'GET',
                            dataType: 'json',
                            success: function(data, textStatus, jqXHR) {
                                if (!data['notFound']) {
                                    if (data['id'] > 0) $.messager.alert('Scenario Updated', 'Updated succesfully!', 'info');
                                    //if(data['id']==0) $.messager.alert('Scenario Updated','Updated succesfully!','info');
                                } else {
                                    $.messager.alert('Update Failure', 'Update failure!', 'error');
                                    /*console.warn('data notfound-->'+textStatus);
                                    $.messager.alert('Pick sub flow and company','Please select  a sub flow from flow tree!','warning');*/
                                }
                                $('#tt_grid_scenarios_details_edit').datagrid('reload');
                            },
                            error: function(jqXHR, textStatus, errorThrown) {
                                console.warn('error text status-->' + textStatus);
                                $.messager.alert('Update Failure', 'Update failure!', 'error');
                            }
                        });
                    }
                });
                //updateActions(index);
            }
        },
        onCancelEdit: function(index, row) {
            console.log('onCancelEdit');
            row.editing = false;
            updateActionsCmpnyFlow(index);
        },
        /*onResize:function(){
            $('#tt_grid_dynamic').datagrid('fixDetailRowHeight',index);
        },
        onLoadSuccess:function(){
            setTimeout(function(){
                $('#tt_grid_dynamic').datagrid('fixDetailRowHeight',index);
            },0);
        }*/
    });
});