// remote connection test
// remote connection test2
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
    // $('#ff').form('submit');
    console.warn($('#tt_grid_dynamic5').datagrid('getRows'));
    $.ajax({
        url: '../../../slim_ecoman/index.php/insertIS',
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
            //console.warn(jqXHR);
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
    //if($('#tt_grid_dynamic4').datagrid('getSelections').length==1){
    console.warn($('#tt_grid_dynamic5').datagrid('getSelections'));
    $.messager.confirm('Confirm', 'Are you sure? Selected row will be deleted...', function(r) {
        if (r) {
            $('#tt_grid_dynamic5').datagrid('deleteRow', getRowIndexAuto(target));
        }
    });
    /*} else {
        $.messager.alert('Pick a row','Please select one row to remove....','warning');
    }*/
}

function addRowAuto() {
    if ($('#tt_grid_dynamic').datagrid('getSelections').length == 1 /*&& $('#tt_grid').datagrid('getSelections').length==1*/ ) {
        $('#tt_grid_dynamic5').datagrid('appendRow', {
            id: '' + $('#tt_grid_dynamic').datagrid('getSelections')[0].id + '',
            company1: $('#tt_grid_dynamic').datagrid('getSelections')[0].company,
            qntty1: $('#tt_grid_dynamic').datagrid('getSelections')[0].qntty,
            company2: $('#tt_grid_dynamic').datagrid('getSelections')[0].tocompany,
            qntty2: $('#tt_grid_dynamic').datagrid('getSelections')[0].qntty2,
            flow: $('#tt_grid_dynamic').datagrid('getSelections')[0].flow,
            flowtype: 'floww type',
        });
        $('#tt_grid_dynamic').datagrid('clearChecked');
    } else {
        $.messager.alert('Pick rows', 'Please select only one row from "Dynamic table with IS potentials" table', 'warning');
    }
}

function savePotentialsAuto() {
    //console.warn($('#tt_grid_dynamic4').datagrid('getRows'));
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
    //console.warn($('#tt_grid_dynamic4').datagrid('getRows'));
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
    //console.warn($("#tt_tree").tree("getSelected"));  
    console.warn($("#tt_tree").tree("getChecked"));
    var checkedArray = Array("");
    checkedArray = $("#tt_tree").tree("getChecked");
    var columnArray = [];
    //columnArray.push({field: 'id',title: 'id',width:100});
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
        if (obj.attributes.notroot) {
            //console.warn(obj.text);
            //columnArray.push({field: obj.text.toLowerCase(),title: obj.text,width:100});
        }
    });
    //console.warn(columnArray);
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
    if ( /*checkedArray.length==0 &&*/ gridCheckedArray.length == 0) {
        $.messager.alert('Pick flow and company', 'Please select  company and sub flow!', 'warning');
    } else if (checkedArray.length > 0 && gridCheckedArray.length > 0) {
        var flowStr = "";
        var companyStr = "";
        //var columnArray = Array();
        //var gridCheckedArray = Array();
        $.each(checkedArray, function(index, obj) {
            if (obj.attributes.notroot) {
                //console.warn(obj.text);
                //columnArray.push({flow: obj.text,id: obj.id});
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
            url: '../../../slim_ecoman/index.php/ISPotentialsNew_json_test',
            type: 'GET',
            dataType: 'json',
            //data: 'selectedFlows='+JSON.stringify(columnArray),
            data: 'selectedFlows=' + flowStr + '&companies=' + companyStr + '&IS=' + $('#IS_search').combobox('getValue'),
            success: function(data, textStatus, jqXHR) {
                if (!data['notFound']) {
                    //console.warn('success text status-->'+textStatus);
                    $('#tt_grid_dynamic').datagrid('loadData', data);
                    $('#tt_grid_dynamic').datagrid({
                        //url : '../slim_ecoman/index.php/ISPotentialsNew?selectedFlows='+flowStr+'&companies='+companyStr
                    });
                    //$('#tt_grid_dynamic2').datagrid('getPanel').panel("setTitle",companyName);
                } else {
                    console.warn('data notfound-->' + textStatus);
                    $.messager.alert('Pick sub flow and company', 'Please select  a sub flow from flow tree!', 'warning');
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.warn('error text status-->' + textStatus);
                //console.warn(jqXHR);
            }
        });
    }
}

function beginISPotential() {
    //var bos = array('');
    $('#tt_grid_dynamic5').datagrid('loadData', []);
    $('#tt_grid_dynamic5').datagrid('loading');
    $('#tt_grid_dynamic5').datagrid('getPanel').panel('setTitle', 'Companies by specific flow');
    if ($('#tt_grid').datagrid('getSelections').length == 1) {} else if ($('#tt_grid').datagrid('getSelections').length > 1) {
        //console.warn($('#tt_grid').datagrid('getSelections')[0].id);
        getCompaniesISPotentials($('#tt_grid2').datagrid('getSelections')[0].id, $('#tt_grid2').datagrid('getSelections')[0].company);
    } else {
        $.messager.alert('Pick a company', 'Please select  company!', 'warning');
    }
}

function getTreeRoots() {
    var treeRoots = $('#tt_tree').tree("getRoots");
    //console.warn(treeRoots);
    $.each(treeRoots, function(index, obj) {
        //console.warn('getTreeRoots object id-->'+obj.id);
        obj.checked = true;
        //console.warn('getTreeRoots object checked?-->'+obj.checked);
    });
    //$('#tt_tree').tree("check",treeRoots[1]);
}
$(function() {
    var treeValue;
    $("#tt_tree").tree({
        onCheck: function(node, checked) {
            //console.warn('oncheck event node id -->'+node.id);
            //console.warn('oncheck event node id -->'+node.text);
            if (checked) {
                //console.warn('oncheck event checked -->'+node.text);
                //console.warn(node.attributes.notroot);
                //$('#tt_grid').datagrid("showColumn",node.text.toLowerCase());
                //$.inArray( 5 + 5, [ "8", "9", "10", 10 + "" ] );
                if (node.attributes.notroot) {
                    //$('#tt_grid').datagrid("showColumn",node.text.toLowerCase());
                    $('#tt_grid').datagrid("showColumn", node.text);
                }
                if (node.children) {
                    $.each(node.children, function(index, obj) {
                        //$('#tt_grid').datagrid("showColumn",obj.text.toLowerCase());
                        $('#tt_grid').datagrid("showColumn", obj.text);
                        //console.warn(node.children);
                    });
                }
            } else {
                //console.warn('oncheck event not checked -->'+node.text);
                //$('#tt_grid').datagrid("hideColumn",node.text.toLowerCase());
                if (node.attributes.notroot) {
                    //$('#tt_grid').datagrid("hideColumn",node.text.toLowerCase());
                    $('#tt_grid').datagrid("hideColumn", node.text);
                }
                if (node.children) {
                    $.each(node.children, function(index, obj) {
                        //$('#tt_grid').datagrid("hideColumn",obj.text.toLowerCase());
                        $('#tt_grid').datagrid("hideColumn", obj.text);
                        //console.warn(node.children);
                    });
                }
            }
        },
        onClick: function(node) {
            var parentnode = $("#tt_tree").tree("getParent", node.target);
            var roots = $("#tt_tree").tree("getRoots");
            //alert("roots-->"+roots[0].text);
            /*
            if(parentnode){
                //alert("parent node bulundu");
            } else {
                //alert("parent node bulunamad�");
            }
            */
            //alert(node.state);
            //alert(parentnode.text);
            var treeValue;
            if (node.state == undefined) {
                //alert("bulu");
                var de = parentnode.text;
                var test_array = de.split("/");
                //alert(test_array[1]);
                treeValue = test_array[1];
            } else {
                treeValue = parentnode.text;
            }
            var imagepath = parentnode.text + "/" + node.text;
        },
        onExpand: function(node) {
            //alert("onExpand");
            var root = $("#tt_tree").tree("getRoot");
            //alert("root text-->"+root.text);
            var parent = $("#tt_tree").tree("getParent", node.target);
            if (parent) {
                //alert("parent text-->"+parent.text);
                //console.warn(node.id);
                var nodes = $('#tt_tree').tree('getChecked');
                var s = '';
                var num = '';
                for (var i = 0; i < nodes.length; i++) {
                    if (s != '') s += ',';
                    s += nodes[i].text;
                    if (num != '') num += ',';
                    num += nodes[i].id;
                }
                //alert(s);
                //console.warn(s);
                //console.warn(num);
            } else {
                treeValue = node.text;
                var nodeId = node.id;
                //console.warn(node.id);
                //alert(treeValue);
                /*
                var roots=$("#tt_tree").tree("getRoots");
                $(roots).each(function(index){
                    if(node.text!=roots[index].text) {
                    $("#tt_tree").tree("collapse", roots[index].target);
                        /*
                        $("#'.$this->_id.'").tree("update", {
                            target: roots[index].target,
                            state: "closed"
                        });
                        */
                /* }
                        });*/
            }
        },
        onCollapse: function(node) {
            //alert("onCollapse");
            var root = $("#tt_tree").tree("getRoot");
            //alert("root text-->"+root.text);
            var parent = $("#tt_tree").tree("getParent", node.target);
            if (parent) {
                //alert("parent text-->"+parent.text);
            } else {
                /*
                console.warn("root eleman id-->"+node.id);
                console.warn("root eleman text-->"+node.text);
                */
                var nodeId = node.id;
                var selections = $('#tt_grid').datagrid("getSelections");
                for (var i = 0; i < selections.length; i++) {
                    //console.warn(selections[i].company);
                }
                //console.warn(selections);
            }
        },
        onDblClick: function(node) {
            //alert("onDblClick");
            var deneme = "test";
            var parent = $("#tt_tree").tree("getParent", node.target);
            if (parent) {} else {
                /*
                $("#w").window("open");
                $("#dg").datagrid({
                    view: detailview,
                    detailFormatter:function(index,row){
                        return "<div id=\'ddv-" + index + "\' style=\'padding:5px 0;overflow:scroll;\'></div>";
                    },
                    onExpandRow: function(index,row){
                    $("#ddv-"+index).panel({
                        height : 500,
                        border:false, 
                        cache:false,
                        href:"projeTarim_detaylar.php?itemid="+row.ProjeTarimId,
                        onLoad:function(){
                            //$("#dg").datagrid("fixDetailRowHeight",index);
                        }
                    });
                    //$("#dg").datagrid("fixDetailRowHeight",index);
                    },
                    url:"projeTarim_gridDoldur.php?ProjeTarimAd="+node.text,
                    columns:[[
                        {field:"ProjeTarimId",title:"Id",width:100},
                        {field:"ProjeTarimAd",title:"Dosya",width:100},
                        {field:"Aktif",title:"Aktif",width:100,align:"right"}
                    ]],
                    fitColumns : true,
                    resizable :true
                 });*/
                /*
                         $("#dg").datagrid("load", {
                            name: "easyui",
                            address: "ho"
                        });
                        */
            }
        }
    });
    $('#tt_tree').tree({
        url: '../../../slim_ecoman/index.php/flows',
        method: 'get',
        animate: true,
        checkbox: true
    });
    //alert('test');
    $('#tt_grid_dynamic').datagrid({
        singleSelect: false,
        /*ctrlSelect:true,*/
        collapsible: true,
        /*url:'datagrid_data1.json',*/
        //url:'../slim_ecoman/index.php/ISPotentials',
        method: 'get',
        idField: 'id',
        toolbar: '#tb5',
        remoteSort: false,
        multiSort: false,
        loadMsg: 'Please wait while loading...',
        fit: true,
        fitColumns: true,
    });
    $.ajax({
        url: '../../../slim_ecoman/index.php/columnflows_json_test',
        type: 'GET',
        dataType: 'json',
        //data: 'rowIndex='+rowData.id,
        success: function(data, textStatus, jqXHR) {
            console.warn('success text status-->' + textStatus);
            $('#tt_grid').datagrid({
                /*singleSelect:false,
                ctrlSelect:true,*/
                collapsible: true,
                /*url:'datagrid_data1.json',*/
                url: '../../../slim_ecoman/index.php/companies_json_test2',
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
                onDblClickRow: function(rowIndex, rowData) {
                    alert(rowIndex);
                    console.warn(rowData);
                    $.ajax({
                        url: '../../../slim_ecoman/index.php/flows',
                        type: 'GET',
                        dataType: 'json',
                        data: 'rowIndex=' + rowData.id,
                        success: function(data, textStatus, jqXHR) {
                            console.warn('success text status-->' + textStatus);
                            //console.warn(jqXHR);
                        },
                        error: function(jqXHR, textStatus, errorThrown) {
                            console.warn('error text status-->' + textStatus);
                            //console.warn(jqXHR);
                        }
                    });
                }
            });
            var gridColumns = $('#tt_grid').datagrid('getColumnFields');
            var arrayFilter = [];
            var arrayFirst = [];
            $.each(gridColumns, function(index, obj) {
                arrayFirst = [];
                /*console.warn('index-->'+index+'');
                console.warn('object-->'+obj+'');
                console.warn('lower case-->'+obj.toLowerCase()+'');*/
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
                /*singleSelect:false,
                ctrlSelect:true,*/
                collapsible: true,
                url: '../../../slim_ecoman/index.php/ISScenarios',
                method: 'get',
                idField: 'id',
                /*toolbar:'#tb',*/
                remoteSort: false,
                multiSort: false,
                loadMsg: 'Please wait while loading...',
                rownumbers: "true",
                pagination: "true",
                //remoteFilter: true,
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
            //console.warn(jqXHR);
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
                },
                //{field:'quality',title:'Quality',width:100},
                {
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
                            //var e = '<a href="#" onclick="editrow(this)">Edit</a> ';
                            //var d = '<a href="#" onclick="deleteISPotential(this)" >Delete</a>';
                            var d = '<button class="btn btn-mini rn_btnDelete" onclick="deleteISPotentialAuto(this)">Delete</button>';
                            //return e+d;
                            return d;
                        }
                    }
                }
            ]
        ],
        //rownumbers: "true",
        //pagination: "true",
        idField: 'id',
        singleSelect: true,
        collapsible: true,
        fitColumns: true,
        toolbar: '#tb6',
        onDblClickRow: function(rowIndex, rowData) {
            //alert(rowIndex);
            console.warn(rowData);
        }
        //width : 500
        //url : '../slim_ecoman/index.php/companyFlows'
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