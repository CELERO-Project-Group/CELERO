function openIsScenarios() {
            //alert('test');
           //$('#tt_grid').datagrid('collapse'); 
           $('#p').panel('collapse');
        }

function beginISPotentialByAllFlows() {
            $.messager.confirm('Confirm','Are you sure ? New Table with new data will be deployed...',function(r){
                    if (r){
                        $.ajax({
                        url: '../../../Proxy/SlimProxy.php',
                        data: { url:'columnflows_json_test'  },
                        type: 'GET',
                        dataType : 'json',
                        //data: 'rowIndex='+rowData.id,
                        success: function(data, textStatus, jqXHR) {
                          console.warn('success text status-->'+textStatus);

                            $('#tt_grid2').datagrid({
                                  sortName : 'cmpny_name',
                                  singleSelect:true,
                                  collapsible:true,
                                  url:'../../../Proxy/SlimProxy.php',
                                  queryParams : { url:'companies_json_test2_manual',
                                                  prj_id : $('#prj_id').val()},
                                  method:'get',
                                  idField:'id',
                                  toolbar:'#tb',
                                  remoteSort:true,
                                  multiSort:false,
                                  rownumbers: "true",
                                  pagination: "true",
                                  columns:[
                                          data
                                      ],
                                  onDblClickRow: function(rowIndex, rowData){
                                        alert(rowIndex);
                                        console.warn(rowData);
                                        $.ajax({
                                            url: '../../../slim2_ecoman/index.php/flows',
                                            type: 'GET',
                                            dataType : 'json',
                                            data: 'rowIndex='+rowData.id,
                                            success: function(data, textStatus, jqXHR) {
                                              console.warn('success text status-->'+textStatus);

                                            },
                                            error: function(jqXHR , textStatus, errorThrown) {
                                              console.warn('error text status-->'+textStatus);
                                            }
                                        }); 
                                }

                          });
                          
                            var gridColumns = $('#tt_grid2').datagrid('getColumnFields');
        
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


                            var dg = $('#tt_grid2').datagrid();
                                dg.datagrid('enableFilter', 
                                arrayFilter
                                ); 


                        },
                        error: function(jqXHR , textStatus, errorThrown) {
                          console.warn('error text status-->'+textStatus);
                        }
                    });
                }
            });
        }
        
        
        
        function beginISPotentialByFlows() {
            $.messager.confirm('Confirm','Are you sure ? New Table with new data will be deployed...',function(r){
                    if (r){
                        var nodes = $('#tt_tree2').tree('getChecked');
                        console.warn(nodes);
                        var arrayLeaf = Array();
                        $.each(nodes, function( index, obj ) {
                            if(obj.attributes.notroot==false) {
                            } else if(obj.attributes.notroot==true) {
                                arrayLeaf.push(obj.id);
                            }

                          });
                          $('#tt_grid2').datagrid({ 
                                url : ''      
                            }); 
                         console.warn(arrayLeaf);
                        $.ajax({
                            url:'../../../Proxy/SlimProxy.php',
                            type: 'GET',
                            dataType : 'json',
                            data : {
                                  url : 'flowsAndCompanies_json_test_manual',
                                  flows : JSON.stringify(arrayLeaf),
                                  prj_id : $('#prj_id').val()
                            },
                            success: function(data, textStatus, jqXHR) {
                              console.warn('success text status-->'+textStatus);
                              $('#tt_grid2').datagrid({
                                  sortName : 'flow',
                                  columns:[[
                                        {field:'company',title:'Company',width:100},
                                        {field:'qntty',title:'Quantity',width:100},
                                        {field:'flow',title:'Flow',width:100,sortable:true},
                                        {field:'unit',title:'Unit',width:100},
                                        {field:'quality',title:'Quality',width:100},
                                        {field:'flowtype',title:'Flow Type',width:100}
                                        ]]});
                              $('#tt_grid2').datagrid('loadData', data);
                              $('#tt_grid2').datagrid({
                                 url :'../../../Proxy/SlimProxy.php',
                                 queryParams : { url : 'flowsAndCompanies_json_test_manual',
                                                 flows : JSON.stringify(arrayLeaf),
                                                 prj_id : $('#prj_id').val()
                                             }
                            });
                            },
                            error: function(jqXHR , textStatus, errorThrown) {
                              console.warn('error text status-->'+textStatus);
                            }
                        }); 
                    }
                });
        }
        
        function windowManualISQuitWithoutSaving () {
            $.messager.confirm('Confirm','Are you sure ? You will close window without saving...',function(r){
                    if (r){
                        $('#saveWindow').window('close');
                    }
                });
        }
        
        function submitForm(){
            $.ajax({
                url: '../../../slim2_ecoman/index.php/insertIS',
                type: 'POST',
                dataType : 'json',
                data: 'row='+JSON.stringify($('#tt_grid_dynamic4').datagrid('getRows'))+'&text='+$('#tt_text').textbox('getText'),
                success: function(data, textStatus, jqXHR) {
                  if(data["found"]==true) {
                      $.messager.alert('Success','Success inserted IS Potential !','info');
                      $('#saveWindow').window('close');
                      $('#tt_grid_dynamic4').datagrid('loadData',[]);
                  } else if(data["notFound"]==true) {
                      $.messager.alert('Insert failed','Failed to insert IS Potential !','error');
                  }
                  
                },
                error: function(jqXHR , textStatus, errorThrown) {
                    console.warn('error text status-->'+textStatus);
                }
            });
        }
        
        function deleteAllISPotential() {
            $.messager.confirm('Confirm','Are you sure ? You will delete all rows...',function(r){
                    if (r){
                        $('#tt_grid_dynamic4').datagrid('loadData',[]);
                    }
                });
        }
        
        function getRowIndex(target){
            var tr = $(target).closest('tr.datagrid-row');
            return parseInt(tr.attr('datagrid-row-index'));
        }
        
        function deleteISPotential(target) {
                console.warn($('#tt_grid_dynamic4').datagrid('getSelections'));
                $.messager.confirm('Confirm','Are you sure? Selected row will be deleted...',function(r){
                    if (r){
                        $('#tt_grid_dynamic4').datagrid('deleteRow', getRowIndex(target));
                    }
                });
        }
        
        function savePotentials() {
            if($('#tt_grid_dynamic4').datagrid('getRows').length==0) {
                $.messager.alert('Fill IS Potentials','Please fill IS Potentials table','warning');
            } else if($('#tt_grid_dynamic4').datagrid('getRows').length>0) {
                rowArray = $('#tt_grid_dynamic4').datagrid('getRows');
                 $("#saveWindow").attr( "IS_synergy" , $('#IS_search2').combobox('getValue'));
                 $('#saveWindow').window('open'); 
                 $("#IS").combobox("setValue",$("#saveWindow").attr( "IS_synergy"));
            }
            
        }
        
        function addRow() {
            if($('#tt_grid_dynamic2').datagrid('getSelections').length==1 && $('#tt_grid_dynamic3').datagrid('getSelections').length==1 && $('#tt_grid2').datagrid('getSelections').length==1) {
                $('#tt_grid_dynamic4').datagrid('appendRow',{id:''+$('#tt_grid2').datagrid('getSelections')[0].id+','
                                                                  +$('#tt_grid_dynamic3').datagrid('getSelections')[0].id+','
                                                                  +$('#tt_grid_dynamic2').datagrid('getSelections')[0].id+'',
                    company1:$('#tt_grid2').datagrid('getSelections')[0].company,
                    qntty1:$('#tt_grid_dynamic2').datagrid('getSelections')[0].qntty,
                    company2:$('#tt_grid_dynamic3').datagrid('getSelections')[0].company,
                    qntty2:$('#tt_grid_dynamic3').datagrid('getSelections')[0].qntty,
                    flow:$('#tt_grid_dynamic2').datagrid('getSelections')[0].flow,
                    flowtype:'floww type',
                    map:''+$('#tt_grid2').datagrid('getSelections')[0].id+','
                            +$('#tt_grid_dynamic3').datagrid('getSelections')[0].id+'',
                    });
                    $('#tt_grid_dynamic3').datagrid('clearChecked');
            } else {
                $.messager.alert('Pick rows','Please select one row from all tables','warning');
            }
            
        }
        
        function getFlowCompanies(index,flowName, companyID) {
            $('#tt_grid_dynamic3').datagrid({  
                      loadMsg :'Please wait while loading...',
                      rownumbers: "true",
                      pagination: "true",
                      idField:'id',
                      singleSelect: true,
                      url : '../../../Proxy/SlimProxy.php',
                      queryParams : {
                            url : 'flowCompanies_json_test_manual',
                            flowid : index,
                            IS3    : $('#IS_search2').combobox('getValue'),
                            cmpny_id : companyID,
                            prj_id : $('#prj_id').val()
                      }
                   });
                   $('#tt_grid_dynamic3').datagrid('getPanel').panel("setTitle",flowName);
        }
        
        function getCompanyFlows(index,companyName) {
            
            $('#tt_grid_dynamic2').datagrid('getPanel').panel("setTitle",companyName);
            $('#tt_grid_dynamic2').datagrid({  
                loadMsg :'Please wait while loading...',
                rownumbers: "true",
                pagination: "true",
                url : '../../../Proxy/SlimProxy.php',
                queryParams : {
                            url : 'companyFlows_json_test_manual',
                            companyid : index,
                            IS2 : $('#IS_search2').combobox('getValue')
                }
             });
        }
        
        function beginFlowPotential() {
            $('#tt_grid_dynamic3').datagrid('loadData',[]);
            $('#tt_grid_dynamic3').datagrid('loading');
            if($('#tt_grid_dynamic2').datagrid('getSelections').length==1) {
                getFlowCompanies($('#tt_grid_dynamic2').datagrid('getSelections')[0].id, $('#tt_grid_dynamic2').datagrid('getSelections')[0].flow, $('#tt_grid2').datagrid('getSelections')[0].id);
            }else if($('#tt_grid_dynamic2').datagrid('getSelections').length>1){
                $.messager.alert('Only one flow at a time','Please select only one flow!','warning');
            } else {
                $.messager.alert('Pick a company','Please select  flow!','warning');
            }
        }
        
        
        function beginISPotential() {
            $('#tt_grid_dynamic2').datagrid('loading');
            $('#tt_grid_dynamic3').datagrid('loading');
            $('#tt_grid_dynamic2').datagrid('loadData',[]);
            $('#tt_grid_dynamic3').datagrid({  
                    url: '',
                   });
            $('#tt_grid_dynamic3').datagrid('loadData',[]);
            
            $('#tt_grid_dynamic3').datagrid('getPanel').panel('setTitle','Companies by specific flow');
            if($('#tt_grid2').datagrid('getSelections').length==1) {
                getCompanyFlows($('#tt_grid2').datagrid('getSelections')[0].id, $('#tt_grid2').datagrid('getSelections')[0].company);
            }else if($('#tt_grid2').datagrid('getSelections').length>1){
                $.messager.alert('Only one company at a time','Please select only one company!','warning');
            } else {
                $.messager.alert('Pick a company','Please select  company!','warning');
            }
        }
        
        function getTreeRoots() {
            var treeRoots = $('#tt_tree2').tree("getRoots");
            $.each(treeRoots, function( index, obj ) {
                obj.checked = true;
                
              });
        }
        

	$(function() {
          
        var treeValue;
        $("#tt_tree2").tree({
                    onCheck: function(node, checked) {
                        if(checked) {
                            if(node.attributes.notroot) {
                                $('#tt_grid2').datagrid("hideColumn",node.text);
                                $('#tt_grid2').datagrid("showColumn",node.text);
                            }
                            if(node.children) {
                                $.each(node.children, function( index, obj ) {
                                    $('#tt_grid2').datagrid("hideColumn",obj.text);
                                    $('#tt_grid2').datagrid("showColumn",obj.text);
                              });
                            }
                        } else {
                            if(node.attributes.notroot) {
                                $('#tt_grid2').datagrid("hideColumn",node.text);
                            }
                            if(node.children) {
                                $.each(node.children, function( index, obj ) {
                                $('#tt_grid2').datagrid("hideColumn",obj.text);
                              });
                            }
                        }
                    },
                    onClick: function(node){
                    var parentnode=$("#tt_tree2").tree("getParent", node.target);
                    var roots=$("#tt_tree2").tree("getRoots");                    
                    var treeValue;
                    if(node.state==undefined) {
                            var de=parentnode.text;
                            var test_array=de.split("/");
                            treeValue=test_array[1];
                    } else {
                            treeValue=parentnode.text;
                    }
    
                    var imagepath=parentnode.text+"/"+node.text;
                },
                onExpand: function(node){
                    var root=$("#tt_tree2").tree("getRoot");
                    var parent=$("#tt_tree2").tree("getParent",node.target);
                    if(parent) {
                        var nodes = $('#tt_tree2').tree('getChecked');
                        var s = '';
                        var num = '';
                        for(var i=0; i<nodes.length; i++){
                            if (s != '') s += ',';
                            s += nodes[i].text;
                            if (num != '') num += ',';
                            num += nodes[i].id;
                        }

                    }else {
                        $("#tt_tree2").tree("check", node.target);
                        treeValue=node.text;
                        var nodeId = node.id;
                    }
                },
                onCollapse: function(node){
                    var root=$("#tt_tree2").tree("getRoot");
                    var parent=$("#tt_tree2").tree("getParent",node.target);
                    if(parent) {
                    }else {
                        var nodeId = node.id;
                        var selections = $('#tt_grid2').datagrid("getSelections");
                        for(var i=0; i<selections.length; i++){
                        }
                    }
                    
                },
                onDblClick: function(node){
                var deneme="test";
                    var parent=$("#tt_tree2").tree("getParent",node.target);
                    if(parent) {
                    
                    } else {
                        
                    }
                    
                    
                }
            });
            
   
    $('#tt_tree2').tree({
        
        url: '../../../Proxy/SlimProxy.php',
        queryParams : { url:'flows' },
        //url:'tree_data1.json',
        method:'get',
        animate:true,
        checkbox:true
    }); 
    
    
    
    
      $('#tt_grid_dynamic2').datagrid({
        columns:[[
            {field:'flow',title:'Flow Category',width:100},
            {field:'qntty',title:'Quantity',width:100},
            {field:'unit',title:'Unit',width:100},
            {field:'quality',title:'Quality',width:100},
            {field:'flowtype',title:'Flow Type',width:100}
        ]],
         idField:'id',
         singleSelect:true,
         collapsible:true,
         fitColumns : true,
         toolbar:'#tb2',
    });
    
    $('#tt_grid_dynamic3').datagrid({
        columns:[[
            {field:'company',title:'Company',width:100},
            {field:'qntty',title:'Quantity',width:100},
            {field:'unit',title:'Unit',width:100},
            {field:'quality',title:'Quality',width:100},
            {field:'flowtype',title:'Flow Type',width:100}
        ]],
         rownumbers: "true",
         pagination: "true",
         idField:'id',
         singleSelect:true,
         collapsible:true,
         fitColumns : true,
         toolbar:'#tb3',
    });
    
    $('#tt_grid_dynamic4').datagrid({
        columns:[[
            {field:'company1',title:'Company',width:100},
            {field:'qntty1',title:'Quantity',width:100},
            {field:'company2',title:'Company',width:100},
            {field:'qntty2',title:'Quantity',width:100},
            {field:'flow',title:'Flow',width:100},
            //{field:'quality',title:'Quality',width:100},
            {field:'flowtype',title:'Flow Type',width:100},
            {field:'action',title:'Action',width:150,align:'center',
                formatter:function(value,row,index){
                    if (row.editing){
                        var s = '<a href="#" onclick="saverow(this)">Save</a> ';
                        var c = '<a href="#" onclick="cancelrow(this)">Cancel</a>';
                        return s+c;
                    } else {
                         var d = '<button class="btn btn-mini rn_btnDelete" onclick="deleteISPotential(this)">Delete</button>';
                        return d;
                    }
                }
            },
            {field:'map',title:'Map',width:200,align:'center',
                formatter:function(value,row,index){
                    if (row.editing){
                        var s = '<a href="#" onclick="saverow(this)">Save</a> ';
                        var c = '<a href="#" onclick="cancelrow(this)">Cancel</a>';
                        return s+c;
                    } else {
                        //var e = '<a href="#" onclick="editrow(this)">Edit</a> ';
                        //var d = '<a href="#" onclick="deleteISPotential(this)" >Delete</a>';
                        console.log('row satır id bilgileri'+row.id);
                        var arrSplit = row.id.split(",");
                         var d = '<button class="btn btn-mini rn_btnDelete" onclick="window.open(\'../IS_OpenLayers/map.php?to_company='+arrSplit[1]+'&from_company='+arrSplit[0]+'\',\'mywindow\',\'width=900,height=900\')">See on Map</button>';
                        //return e+d;
                        return d;
                    }
                }
            }
        ]],
         idField:'id',
         singleSelect:true,
         collapsible:true,
         fitColumns : true,
         toolbar:'#tb4',
         onDblClickRow: function(rowIndex, rowData){
                      console.warn(rowData); 
              }
    });
    
    
    /**
    *  @todo buras� dinamik kolon yap�s� i�in denenecek
     */
    $.ajax({
        url: '../../../Proxy/SlimProxy.php',
        data: { url:'columnflows_json_test'  },
        type: 'GET',
        dataType : 'json',
        success: function(data, textStatus, jqXHR) {
          console.warn('success text status-->'+textStatus);
          
          $('#tt_grid2').datagrid({
                singleSelect:true,
                collapsible:true,
                url:'../../../Proxy/SlimProxy.php',
                queryParams : { url:'companies_json_test2_manual',
                                prj_id : $('#prj_id').val() },
                method:'get',
                idField:'id',
                toolbar:'#tb',
                remoteSort:true,
                multiSort:false,
                rownumbers: "true",
                pagination: "true",
                remoteFilter: true,
                columns:[
                        data
                    ],
                onDblClickRow: function(rowIndex, rowData){
              }

        });
        
        var gridColumns = $('#tt_grid2').datagrid('getColumnFields');
        
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
        
        
        var dg = $('#tt_grid2').datagrid();
            dg.datagrid('enableFilter', 
            arrayFilter
            ); 
          $('#tt_grid_scenarios2').datagrid({
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
                        ]]
        });

        },
        error: function(jqXHR , textStatus, errorThrown) {
          console.warn('error text status-->'+textStatus);
        }
    }); 
    
    $('#printGrid2').click(function() {
        
        $.print("#tt_grid_div2");
    });

    
     $('#printGridPotentials2').click(function() {
        
        $.print("#tt_grid_dynamic2_div");
    });
    
    $('#printGridPotentials3').click(function() {
        
        $.print("#tt_grid_dynamic3_div");
    });
    
     
});  


