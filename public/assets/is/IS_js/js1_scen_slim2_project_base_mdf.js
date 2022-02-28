// remote connection test
// remote connection test2
function closeMapPanel() {
    //var panelWest = $('#cc').layout('panel','south');
    //var panelSouthNorth = $('#cc2').layout('panel','north');
    $('#cc2').layout('collapse', 'north');
}

function showMapPanelExpand() {
    //var panelWest = $('#cc').layout('panel','south');
    //var panelSouthNorth = $('#cc2').layout('panel','north');
    $('#cc2').layout('expand', 'north');
}

function saveISScenarioAuto() {
    $.messager.progress();
    $('#ff').form({
        ajax: true,
        url: '../../../slim2_ecoman/index.php/insertIS',
        queryParams: {
            row: JSON.stringify($('#tt_grid_dynamic5').datagrid('getRows')),
            text: $('#tt_textAuto').textbox('getText'),
            consultant_id: document.getElementById('consultant_id').value,
            prj_id: document.getElementById('prj_id').value
            //'row='+JSON.stringify($('#tt_grid_dynamic5').datagrid('getRows'))+'&text='+$('#tt_textAuto').textbox('getText')
        },
        onSubmit: function() {
            var isValid = $(this).form('validate');
            if (!isValid) {
                $.messager.progress('close');
            }
            //$.messager.alert('is valid ');
            return isValid; // return false will stop the form submission
        },
        success: function(data) {
            var jsonObj = $.parseJSON(data);
            if (jsonObj['found'] == true) {
                $.messager.alert('Succesfully saved', 'Data succesfully saved');
                $.messager.progress('close'); // hide progress bar while submit successfully
                $('#saveWindowAuto').window('close');
            } else {
                $.messager.alert('Save Error', 'Error occured');
                $.messager.progress('close'); // hide progress bar while submit successfully
                $('#saveWindowAuto').window('close');
            }
        }
    });
    $('#ff').submit();
}

function updateActions(index) {
    //console.log(index);
    console.log('updateActions');
    var row = $('#tt_grid').datagrid('getSelected');
    /*console.log('updateActions');
    console.log(row);*/
    $('#tt_grid').datagrid('updateRow', {
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
    var rows = $('#tt_grid').datagrid('getRows');
    var row = rows[getRowIndex(target)];
    console.log(row);
    //$('#tt').datagrid('selectRow',getRowIndex(target));
    $('#tt_grid').datagrid('beginEdit', getRowIndex(target));
}

function deleterow(target) {
    /*$.messager.confirm('Confirm','Are you sure?',function(r){
            if (r){
                    $('#tt_grid_scenarios').datagrid('deleteRow', getRowIndex(target));
            }
    });*/
    $.messager.confirm('Confirm', 'Are you sure? Selected row will be deleted...', function(r) {
        if (r) {
            var rows = $('#tt_grid').datagrid('getRows');
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
                    $('#tt_grid').datagrid('reload');
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
    $('#tt_grid').datagrid('endEdit', getRowIndex(target));
    var rows = $('#tt_grid').datagrid('getRows');
    var row = rows[getRowIndex(target)];
    console.log(row);
    //console.error(getRowIndex(target));
}

function cancelrow(target) {
    $('#tt_grid').datagrid('cancelEdit', getRowIndex(target));
}

function insert() {
    var row = $('#tt_grid').datagrid('getSelected');
    if (row) {
        var index = $('#tt_grid').datagrid('getRowIndex', row);
    } else {
        index = 0;
    }
    /*$('#tt_grid_scenarios').datagrid('insertRow', {
            index: index,
            row:{
                    status:'P'
            }
    });*/
    $('#tt_grid').datagrid('selectRow', index);
    $('#tt_grid').datagrid('beginEdit', index);
}

function openIsScenarios() {
    //alert('test');
    //$('#tt_grid').datagrid('collapse'); 
    $('#p').panel('collapse');
}

function selectAllCompanies() {
    $('#tt_grid').datagrid('selectAll');
}

function unselectAllCompanies() {
    $('#tt_grid').datagrid('unselectAll');
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
                /*flowtype:'floww type',*/
            });
        });
        $('#tt_grid_dynamic').datagrid('clearChecked');
    } else {
        $.messager.alert('Pick rows', 'Please select at least one row "Dynamic table with IS potentials" table', 'warning');
    }
}

function savePotentialsAuto() {
    if ($('#tt_grid_dynamic5').datagrid('getRows').length == 0) {
        $.messager.alert('Fill IS Potentials', 'Please add at least one IS Potential to the list', 'warning');
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
        var IS_search = $('#IS_search').combobox('getValue');
        $('#IS').combobox('setValue', IS_search);
        $.each(rowArray, function(index, obj) {
            console.warn(obj);
            window.scrollTo(0, 0);
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
        width: 100,
        sortable: true
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
    /*$('#tt_grid_dynamic').datagrid({
        
        columns:[
                columnArray
        ], 
    });*/
}

function getCompaniesISPotentials() {
    $('#tt_grid_dynamic').datagrid('loaded');
    checkedArray = $("#tt_tree").tree("getChecked");
    gridCheckedArray = $("#tt_grid").datagrid("getSelections");
    console.warn(checkedArray.length);
    console.warn(gridCheckedArray.length);
    if (gridCheckedArray.length == 0 && checkedArray.length == 0) {
        $.messager.alert('Pick flow and company ', 'Please select at least one flow on the left and a company flow!', 'warning');
        $('#matchbutton').attr("href", "#");
    } else if (gridCheckedArray.length == 0) {
        $.messager.alert('Pick company ', 'Please select at least one company flow!', 'warning');
        $('#matchbutton').attr("href", "#");
    } else if (checkedArray.length == 0) {
        $.messager.alert('Pick flow ', 'Please select at least one sub flow on the left!', 'warning');
        $('#matchbutton').attr("href", "#");
    } else if (checkedArray.length > 0 && gridCheckedArray.length > 0) {
        $('#matchbutton').attr("href", "#add");
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
                url: 'ISPotentialsNew_json_test_by_project_prj',
                selectedFlows: flowStr,
                companies: companyStr,
                IS: $('#IS_search').combobox('getValue'),
                //prjId : $('#IS_project').combobox('getValue')
                prj_id: $('#prj_id').val()
            },
            type: 'GET',
            dataType: 'json',
            success: function(data, textStatus, jqXHR) {
                if (!data['notFound']) {
                    $('#tt_grid_dynamic').datagrid('loadData', data);
                    /*$('#tt_grid_dynamic').datagrid({
                                    view: detailview,
                                   detailFormatter:function(index,row){
                                       return '<div class="ddv" style="padding:5px 0">\n\
                                                   <div id="oneri1">sssss</div>\n\
                                                   <div id="oneri2">sss</div>\n\
                                                   <div id="oneri3">sssss</div>\n\
                                               </div>';
                                   },
                                   onExpandRow: function(index,row){
                                       alert('test');
                                       var ddv = $(this).datagrid('getRowDetail',index).find('div.ddv');
                                       ddv.panel({
                                           height:80,
                                           border:false,
                                           cache:false,
                                           href:'',
                                           onLoad:function(){
                                               $('#tt_grid_dynamic').datagrid('fixDetailRowHeight',index);
                                           }
                                       });
                                       $('#tt_grid_dynamic').datagrid('fixDetailRowHeight',index);
                                   }

                       });*/
                } else {
                    console.warn('data notfound-->' + textStatus);
                    //$.messager.alert('Pick sub flow and company','Please select  a sub flow from flow tree!','warning');
                    $.messager.alert('Pick other options', 'There is no IS potentials for the selected company with this flow category. Please select another company and/or flow category', 'warning');
                    /*$('#tt_grid_dynamic').datagrid({
                        loadMsg:'No symbiosis detected'
                    });*/
                    $('#tt_grid_dynamic').datagrid('reload');
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
            //alert('on check test');  
            $("#tt_tree").tree('expand', node.target);
            console.log($("#tt_tree").tree('getChildren', node.target));
            //$("#tt_tree").tree('collapse', node.target);
            //alert('on check test2'); 
            if (checked) {
                //alert('on check test2');
                /*if(node.attributes.notroot) {
                    $('#tt_grid').datagrid("hideColumn",node.text);
                    $('#tt_grid').datagrid("showColumn",node.text);
                    console.error($('#tt_grid').datagrid('getColumnFields'));
                }*/
                if (node.children) {
                    //alert('on check test3');
                    $.each(node.children, function(index, obj) {
                        //console.log(obj);
                        //$("#tt_tree").tree("check", obj.target);
                        //$('#tt_grid').datagrid("hideColumn",obj.text);
                        //$('#tt_grid').datagrid("showColumn",obj.text);
                    });
                }
            } else {
                /*if(node.attributes.notroot) {
                    $('#tt_grid').datagrid("hideColumn",node.text);
                }*/
                if (node.children) {
                    $.each(node.children, function(index, obj) {
                        $("#tt_tree").tree("check", obj.target);
                        //$('#tt_grid').datagrid("hideColumn",obj.text);
                    });
                }
            }
        },
        onClick: function(node) {
            //alert('on click  test');
            $("#tt_tree").tree('expand', node.target);
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
                // $("#tt_tree").tree("check",node.target);
                //alert('test2');
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
                $("#tt_tree").tree("check", node.target);
                //alert('test3');
                treeValue = node.text;
                var nodeId = node.id;
            }
        },
        onCollapse: function(node) {
            /*var root=$("#tt_tree").tree("getRoot");
            var parent=$("#tt_tree").tree("getParent",node.target);
            //alert('test');
            if(parent) {
            }else {
                var nodeId = node.id;
                var selections = $('#tt_grid').datagrid("getSelections");
                for(var i=0; i<selections.length; i++){
                }
            }*/
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
        singleSelect: true,
        url: '../../../Proxy/SlimProxy.php',
        loadMsg: 'No symbiosis detected',
        queryParams: {
            url: 'ISPotentialsNew_json_test_by_project_prj'
        },
        collapsible: true,
        method: 'get',
        idField: 'id',
        toolbar: '#tb5',
        remoteSort: false,
        multiSort: false,
        columns: [
            [
                //{field:'sirket_id',title:'ID',width:300},
                //{field: 'ck',title: 'From Company',checkbox:true},
                {
                    field: 'company',
                    title: 'From Company',
                    width: 100
                }, {
                    field: 'flow',
                    title: 'Flow',
                    width: 100 /*,sortable:true*/
                }, {
                    field: 'qntty',
                    title: 'Quantity',
                    width: 100
                }, {
                    field: 'qnttyunit',
                    title: 'Unit',
                    width: 100
                }, {
                    field: 'fromflowtype',
                    title: 'Flow Type',
                    width: 100
                }, {
                    field: 'tocompany',
                    title: ' To Company',
                    width: 100
                }, {
                    field: 'qntty2',
                    title: 'Quantity',
                    width: 100
                }, {
                    field: 'qntty2unit',
                    title: 'Unit',
                    width: 100
                }, {
                    field: 'toflowtype',
                    title: 'Flow Type',
                    width: 100
                },
            ]
        ],
        fit: true,
        fitColumns: true,
        view: detailview,
        detailFormatter: function(index, row) {
            return '<div style="padding:2px"><table class="ddv"></table></div>';
        },
        onCollapseRow: function(index, row) {
            //alert('oncollapse row');
            var panelWest = $('#cc2').layout('panel', 'west');
            var panelCenter = $('#cc2').layout('panel', 'center');
            panelCenter.panel('open');
            panelCenter.panel('resize', {
                //width:'10%',
                width: '50%',
                height: 300
            });
            panelWest.panel('resize', {
                //width:'10%',
                width: '50%',
                height: 300
            });
        },
        onExpandRow: function(index, row) {
            //alert('test'); 
            var panelWest = $('#cc2').layout('panel', 'west');
            var panelCenter = $('#cc2').layout('panel', 'center');
            //console.log(panelCenter);
            //panelobj.panel('close');
            /*panelCenter.panel('resize', {
                    width:'7%',
                    //width:100,
                    height:300
            });*/
            //panelCenter.panel('close');
            /*panelWest.panel('resize', {
                    //width:'10%',
                    width:'100%',
                    height:300
            });*/
            //$('#tt_grid_dynamic').datagrid('fixDetailRowHeight',index);
            //$('#ccTable').layout('resize');
            //$('#tt_grid_dynamic').datagrid('resize');
            //resize
            var rowExpander = $(this).datagrid('getExpander');
            console.warn(rowExpander);
            var ddv = $(this).datagrid('getRowDetail', index).find('table.ddv');
            console.warn(ddv);
            console.warn($(this).datagrid('getRowDetail', index));
            console.error(row.id);
            var strReq = row.id;
            var splitArr = strReq.split(",");
            console.error(splitArr);
            var regArr = {
                'from': splitArr[0],
                'to': splitArr[1],
                'flow': splitArr[2]
            };
            ddv.datagrid({
                url: '../../../Proxy/SlimProxy.php',
                queryParams: {
                    url: 'getFlowDetails_prj',
                    items: JSON.stringify(regArr)
                },
                fitColumns: true,
                //fit : true,
                singleSelect: true,
                rownumbers: true,
                loadMsg: '',
                height: 'auto',
                columns: [
                    [{
                        field: 'company',
                        title: 'Company',
                        width: 200
                    }, {
                        field: 'potential_energy',
                        title: 'Potential Energy',
                        width: 200
                    }, {
                        field: 'potential_energy_unit',
                        title: 'Potential Energy Unit',
                        width: 200
                    }, {
                        field: 'supply_cost',
                        title: 'Supply Cost',
                        width: 200
                    }, {
                        field: 'supply_cost_unit',
                        title: 'Supply Cost Unit',
                        width: 200
                    }, {
                        field: 'transport_id',
                        title: 'Transport',
                        width: 200
                    }, {
                        field: 'entry_date',
                        title: 'Entry Date',
                        width: 200
                    }, {
                        field: 'concentration',
                        title: 'Concentration',
                        width: 200
                    }, {
                        field: 'pression',
                        title: 'Press.',
                        width: 200
                    }, {
                        field: 'state_id',
                        title: 'State',
                        width: 200
                    }, {
                        field: 'min_flow_rate',
                        title: 'Min Flow Rate',
                        width: 200
                    }, {
                        field: 'min_flow_rate_unit',
                        title: 'Min Flow Rate Unit',
                        width: 200
                    }, {
                        field: 'max_flow_rate',
                        title: 'Max Flow Rate',
                        width: 200
                    }, {
                        field: 'max_flow_rate_unit',
                        title: 'Max Flow Rate Unit',
                        width: 200
                    }, {
                        field: 'substitute_potential',
                        title: 'Substitute Potential',
                        width: 200
                    }, {
                        field: 'quality',
                        title: 'Quality',
                        width: 100
                    }, {
                        field: 'ep_unit_id',
                        title: 'Ep Unit',
                        width: 100
                    }, {
                        field: 'comment',
                        title: 'Comment',
                        width: 100
                    }, {
                        field: 'description',
                        title: 'Description',
                        width: 100
                    }, {
                        field: 'link',
                        title: 'Link',
                        width: 80,
                        align: 'center',
                        formatter: function(value, row, index) {
                            //var link = '<a href="new_flow/'+row.id+'" onclick="" class="easyui-linkbutton" iconCls="icon-back" plain="true">Dataset Management</a>';
                            var link = '<a href="#" onclick="event.preventDefault();window.open(\'new_flow/' + row.id + '\', \'_blank\')" class="easyui-linkbutton" iconCls="icon-back" plain="true">Dataset Management</a>';
                            return link;
                        }
                    }]
                ],
                onResize: function() {
                    //alert('on resize');
                    var panelWest = $('#cc2').layout('panel', 'west');
                    var panelCenter = $('#cc2').layout('panel', 'center');
                    panelCenter.panel('close');
                    panelWest.panel('resize', {
                        //width:'10%',
                        width: '100%',
                        height: 300
                    });
                    $('#tt_grid_dynamic').datagrid('fixDetailRowHeight', index);
                },
                onLoadSuccess: function() {
                    setTimeout(function() {
                        $('#tt_grid_dynamic').datagrid('fixDetailRowHeight', index);
                    }, 0);
                }
            });
            $('#tt_grid_dynamic').datagrid('fixDetailRowHeight', index);
        },
    });
    /*$.ajax({
        url: '../../../Proxy/SlimProxy.php',
        data: { url:'columnflows_json_test'  },
        type: 'GET',
        dataType : 'json',
        success: function(data, textStatus, jqXHR) {
          console.warn('success text status-->'+textStatus);
          
          $('#tt_grid').datagrid({
                collapsible:true,
                url:'../../../Proxy/SlimProxy.php',
                queryParams : { url:'companies_json_test2_prj',
                                prj_id : $('#prj_id').val()},    
                method:'get',
                idField:'id',
                toolbar:'#tb',
                remoteSort:true,
                multiSort:false,
                loadMsg :'Please wait while loading...',
                rownumbers: "true",
                pagination: "true",
                remoteFilter: true,
                columns:[
                        data
                    ],
                onDblClickRow: function(rowIndex, rowData){ 
              },
        });
        
        var gridColumns = $('#tt_grid').datagrid('getColumnFields');
        
        var arrayFilter = [];
        var arrayFirst =[];
        $.each(gridColumns, function( index, obj ) {
                                arrayFirst =[];
                                if(obj.toLowerCase()=='company'){ 
                                    return true;
                                   
                                }
                                 arrayFirst = {field:obj, 
                                            type:'numberbox',
                                            options:{precision:1},
                                            op:['equal','notequal','less','greater']};
                                arrayFilter.push(arrayFirst); 
                                
                              });
        
      
        var dg = $('#tt_grid').datagrid();
            dg.datagrid('enableFilter', 
            arrayFilter
            
            ); 
        
  
        $('#tt_grid_scenarios').datagrid({
                collapsible:true,
                url : '../../../Proxy/SlimProxy.php',
                queryParams : {
                        url : 'ISScenarios'      
                },
                method:'get',
                idField:'id',
                remoteSort:false,
                multiSort:false,
                rownumbers: "true",
                pagination: "true",
                fit:true,
                pagePosition : "top",
                columns:[[
                            {field:'prj_name',title:'Project Name',width:300},
                            {field:'syn_name',title:'Synergy Type',width:300},
                            {field:'date',title:' Project Date',width:300},
                            {field:'detail',title:' Details',width:100}
                        ]]
        });

        },
        error: function(jqXHR , textStatus, errorThrown) {
          console.warn('error text status-->'+textStatus);
        }
    }); */
    //new company flow table
    $('#tt_grid').datagrid({
        url: '../../../Proxy/SlimProxy.php',
        queryParams: {
            url: 'flowsAndCompanies_json_test_MDF_manual',
            //flows : JSON.stringify(arrayLeaf),
            prj_id: $('#prj_id').val()
        },
        sortName: 'company',
        collapsible: true,
        //idField:'id',
        toolbar: '#tb',
        rownumbers: "true",
        pagination: "true",
        remoteSort: true,
        multiSort: true,
        nowrap: false,
        columns: [
            [{
                    field: 'company',
                    title: 'Company',
                    width: 100,
                    sortable: true
                }, {
                    field: 'flow',
                    title: 'Flow',
                    width: 100,
                    sortable: true
                }, {
                    field: 'flowtype',
                    title: 'Flow Type',
                    width: 100
                }, {
                    field: 'flow_family_name',
                    title: 'Flow Family',
                    width: 100
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
                    field: 'unit',
                    title: 'Unit',
                    width: 100
                }, {
                    field: 'cost',
                    title: 'Cost',
                    width: 100,
                    editor: {
                        type: 'numberbox',
                        options: {
                            precision: 2
                        }
                    }
                }, {
                    field: 'description',
                    title: 'Description',
                    width: 600,
                    editor: {
                        type: 'textbox'
                    }
                }, {
                    field: 'action',
                    title: 'Action',
                    width: 150,
                    align: 'center',
                    formatter: function(value, row, index) {
                        var link = '<a href="#" onclick="event.preventDefault();window.open(\'edit_flow/' + row.id + '/' + row.flowID + '/' + row.flowTypeID + '\', \'_blank\')" class="easyui-linkbutton" iconCls="icon-back" plain="true">Dataset Management</a>';
                        return link;
                        /*if (row.editing){
                                var s = '<a href="javascript:void(0)" onclick="saverow(this)">Save</a> ';
                                var c = '<a href="javascript:void(0)" onclick="cancelrow(this)">Cancel</a>';
                                return s+c;
                        } else {
                                var e = '<a href="javascript:void(0)" onclick="editrow(this)">Edit</a> ';
                                //var d = '<a href="javascript:void(0)" onclick="deleteISScenario(this);">Delete</a>';
                                var d = '<a href="javascript:void(0)" onclick="deleterow(this);">Delete</a>';
                                return e+d;
                        }*/
                    }
                }
                //{field:'quality',title:'Quality',width:100},
            ]
        ],
        onBeforeEdit: function(index, row) {
            row.editing = true;
            updateActions(index);
        },
        onAfterEdit: function(index, row) {
            console.log(row);
            console.log('onAfterEdit');
            if ( /*row.prj_name==''*/ true) {
                $.messager.alert('Warning', 'Fill Scenario Name!', 'warning');
            } else {
                /*row.editing = false;
                $.messager.confirm('Confirm','Are you sure? Scenario name will be updated...',function(r){
                    if (r){

                        console.log(row);
                        $.ajax({
                            url : '../../../Proxy/SlimProxy.php',   
                            data : {
                                    url : 'updateScenario_scn',
                                    id : row.id,
                                    scenario : row.prj_name
                            },
                            type: 'GET',
                            dataType : 'json',
                            success: function(data, textStatus, jqXHR) {


                                if(!data['notFound']) {
                                    if(data['id']>0) $.messager.alert('Scenario Updated','Updated succesfully!','info');
                                    //if(data['id']==0) $.messager.alert('Scenario Updated','Updated succesfully!','info');
                                } else {
                                    $.messager.alert('Update Failure','Update failure!','error');
                                    /*console.warn('data notfound-->'+textStatus);
                                    $.messager.alert('Pick sub flow and company','Please select  a sub flow from flow tree!','warning');*/
                /*}
                                    $('#tt_grid_scenarios').datagrid('reload');
                                },
                                error: function(jqXHR , textStatus, errorThrown) {
                                  console.warn('error text status-->'+textStatus);
                                  $.messager.alert('Update Failure','Update failure!','error');
                                }
                            });
                        }
                    });*/
                //updateActions(index);
            }
        },
        onCancelEdit: function(index, row) {
            console.log('onCancelEdit');
            row.editing = false;
            updateActions(index);
        }
    });
    //$('#tt_grid2').datagrid('loadData', data);
    /*$('#tt_grid').datagrid({
       url :'../../../Proxy/SlimProxy.php',
       queryParams : { url : 'flowsAndCompanies_json_test_MDF_manual',
                       //flows : JSON.stringify(arrayLeaf),
                       prj_id : $('#prj_id').val()
                   }
    });*/
    /*$('#tt_grid_scenarios').datagrid({
                collapsible:true,
                url : '../../../Proxy/SlimProxy.php',
                queryParams : {
                        url : 'ISScenarios'      
                },
                method:'get',
                idField:'id',
                remoteSort:false,
                multiSort:false,
                rownumbers: "true",
                pagination: "true",
                fit:true,
                pagePosition : "top",
                columns:[[
                            {field:'prj_name',title:'IS Table Name',width:300},
                            {field:'syn_name',title:'Synergy Type',width:300},
                            {field:'date',title:' Project Date',width:300},
                            {field:'detail',title:' Details',width:100}
                        ]],
                //closed:true,
                //minimized:true,
        });
    $('#p2').panel('collapse');*/
    $('#tt_grid_dynamic5').datagrid({
        fit: true,
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
                title: 'Flow Type',
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
                        //var d = '<button class="btn btn-mini rn_btnDelete" onclick="deleteISPotentialAuto(this)">Delete</button>';
                        var d = '<a href="#add" class="easyui-linkbutton" onclick="deleteISPotentialAuto(this)">Delete</a>';
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
                        var d = '<button class="btn btn-mini rn_btnDelete" \n\
                                            onclick="window.open(\'../IS_OpenLayers/map.php?to_company=' + arrSplit[1] + '&from_company=' + arrSplit[0] + '&prj_id=' + document.getElementById('prj_id').value + '\',\n\
                                            \'mywindow\',\'width=900,height=900\')">\n\
                                                See on Map</button>';
                        //var x = '<button onclick="document.getElementById(\'myFrame\').setAttribute(\'src\',\'../IS_OpenLayers/map.php?to_company='+arrSplit[1]+'&from_company='+arrSplit[0]+'&prj_id='+document.getElementById('prj_id').value+'\')"> See on Map</button>';
                        /*var x = '<a href="#add" class="easyui-linkbutton" iconCls="icon-save" \n\
                                    onclick="document.getElementById(\'myFrame\').setAttribute(\'src\',\'../IS_OpenLayers/map.php?to_company='+arrSplit[1]+'&from_company='+arrSplit[0]+'&prj_id='+document.getElementById('prj_id').value+'\')"> See on Map</a>';*/
                        var x = '<a href="#" class="easyui-linkbutton" iconCls="icon-save" \n\
                            onclick="showMapPanelExpand();\n\
                            document.getElementById(\'myFrame\').setAttribute(\'src\',\'../IS_OpenLayers/map.php?to_company=' + arrSplit[1] + '&from_company=' + arrSplit[0] + '&prj_id=' + document.getElementById('prj_id').value + '\')\n\
                            ;event.preventDefault();"> See on Map</a>';
                        //return e+d;
                        return x;
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
});

function windowManualISQuitWithoutSaving() {
    $('#saveWindowAuto').window('close');
}