function beginISPotentialByAllFlows() {
            $.messager.confirm('Confirm','Are you sure ? New Table with new data will be deployed...',function(r){
                    if (r){
                        $('#tt_grid2').datagrid('loadData',[]);
                        $.ajax({
                        url: '../../../slim_ecoman/index.php/columnflows_json_test',
                        type: 'GET',
                        dataType : 'json',
                        //data: 'rowIndex='+rowData.id,
                        success: function(data, textStatus, jqXHR) {
                          console.warn('success text status-->'+textStatus);

                            $('#tt_grid2').datagrid({
                                  sortName : 'cmpny_name',
                                  singleSelect:true,
                                  /*ctrlSelect:true,*/
                                  collapsible:true,
                                  /*url:'datagrid_data1.json',*/
                                  url:'../../..slim_ecoman/index.php/companies_json_test2',
                                  method:'get',
                                  idField:'id',
                                  toolbar:'#tb',
                                  remoteSort:true,
                                  multiSort:false,
                                  //loadMsg :'Please wait while loading...',
                                  rownumbers: "true",
                                  pagination: "true",
                                  //height : 700,
                                  columns:[
                                          data
                                      ],
                                  onDblClickRow: function(rowIndex, rowData){
                                        alert(rowIndex);
                                        console.warn(rowData);
                                        $.ajax({
                                            url: '../../../slim_ecoman/index.php/flows',
                                            type: 'GET',
                                            dataType : 'json',
                                            data: 'rowIndex='+rowData.id,
                                            success: function(data, textStatus, jqXHR) {
                                              console.warn('success text status-->'+textStatus);
                                              //console.warn(jqXHR);

                                            },
                                            error: function(jqXHR , textStatus, errorThrown) {
                                              console.warn('error text status-->'+textStatus);
                                              //console.warn(jqXHR);
                                            }
                                        }); 
                                }

                          });
                          
                            var gridColumns = $('#tt_grid2').datagrid('getColumnFields');
        
                            var arrayFilter = [];
                            var arrayFirst =[];
                            $.each(gridColumns, function( index, obj ) {
                                                    arrayFirst =[];
                                                    /*console.warn('index-->'+index+'');
                                                    console.warn('object-->'+obj+'');
                                                    console.warn('lower case-->'+obj.toLowerCase()+'');*/
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
                          //console.warn(jqXHR);
                        }
                    });
                }
            });
        }
        
        
        
        function beginISPotentialByFlows() {
            $.messager.confirm('Confirm','Are you sure ? New Table with new data will be deployed...',function(r){
                    if (r){
                        $('#tt_grid2').datagrid('loadData',[]);
                        //console.warn($('#tt_tree2').tree('getChecked'));
                        var nodes = $('#tt_tree2').tree('getChecked');
                        //var treeRoots = $('#tt_tree2').tree("getRoots");
                        console.warn(nodes);
                        var arrayLeaf = Array();
                        $.each(nodes, function( index, obj ) {
                            if(obj.attributes.notroot==false) {
                                //console.warn('root eleman');
                            } else if(obj.attributes.notroot==true) {
                                //console.warn('not root eleman');
                                arrayLeaf.push(obj.id);
                            }
                            //console.warn(obj);
                            /*console.warn('getTreeRoots object id-->'+obj.id);
                            console.warn($('#tt_tree2').tree("find",obj.id));
                            console.warn(obj.target.parentElement);
                            */

                          });
                         console.warn(arrayLeaf);
                        $.ajax({
                            url: '../../../slim_ecoman/index.php/flowsAndCompanies_json_test',
                            type: 'GET',
                            dataType : 'json',
                            data: 'flows='+JSON.stringify(arrayLeaf),
                            success: function(data, textStatus, jqXHR) {
                              console.warn('success text status-->'+textStatus);
                              $('#tt_grid2').datagrid({
                                  sortName : 'company',
                                  columns:[[
                                        {field:'company',title:'Company',width:100},
                                        {field:'qntty',title:'Quantity',width:100},
                                        {field:'flow',title:'Flow',width:100},
                                        {field:'unit',title:'Unit',width:100},
                                        {field:'quality',title:'Quality',width:100},
                                        {field:'flowtype',title:'I/O',width:100}
                                        ]]});
                              $('#tt_grid2').datagrid('loadData', data);
                              $('#tt_grid2').datagrid({

                                 url : '../../../slim_ecoman/index.php/flowsAndCompanies_json_test?flows='+JSON.stringify(arrayLeaf)
                            });
                           /*$("#tt_tree2").tree({
                                checkbox :false
                            });*/
                              //$('#tt_grid2').datagrid('getPanel').panel("setTitle",flowName);

                            },
                            error: function(jqXHR , textStatus, errorThrown) {
                              console.warn('error text status-->'+textStatus);
                              //console.warn(jqXHR);
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
           // $('#ff').form('submit');
            console.warn($('#tt_grid_dynamic4').datagrid('getRows'));
            $.ajax({
                url: '../../../slim_ecoman/index.php/insertIS',
                type: 'POST',
                dataType : 'json',
                data: 'row='+JSON.stringify($('#tt_grid_dynamic4').datagrid('getRows'))+'&text='+$('#tt_text').textbox('getText'),
                success: function(data, textStatus, jqXHR) {
                  console.warn('success text status-->'+textStatus);
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
                  //console.warn(jqXHR);
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

            //if($('#tt_grid_dynamic4').datagrid('getSelections').length==1){
                console.warn($('#tt_grid_dynamic4').datagrid('getSelections'));
                $.messager.confirm('Confirm','Are you sure? Selected row will be deleted...',function(r){
                    if (r){
                        $('#tt_grid_dynamic4').datagrid('deleteRow', getRowIndex(target));
                    }
                });
            /*} else {
                $.messager.alert('Pick a row','Please select one row to remove....','warning');
            }*/
        }
        
        function savePotentials() {
            //console.warn($('#tt_grid_dynamic4').datagrid('getRows'));
            if($('#tt_grid_dynamic4').datagrid('getRows').length==0) {
                $.messager.alert('Fill IS Potentials','Please fill IS Potentials table','warning');
            } else if($('#tt_grid_dynamic4').datagrid('getRows').length>0) {
                rowArray = $('#tt_grid_dynamic4').datagrid('getRows');
                /*$.each(rowArray, function( index, obj ) {
                     console.warn(obj);
                     
                 });*/
                 $("#saveWindow").attr( "IS_synergy" , $('#IS_search2').combobox('getValue'));
                 $('#saveWindow').window('open'); 
                 //console.log($("#saveWindow").attr( "IS_synergy"));
                 //console.log($("#IS").combobox("getValue"));
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
                    flowtype:'floww type',});
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
                      //
                      url: '../../../slim_ecoman/index.php/flowCompanies_json_test?flowid='+index+'&IS3='+$('#IS_search2').combobox('getValue')+'&cmpny_id='+companyID,
                   });
                   $('#tt_grid_dynamic3').datagrid('getPanel').panel("setTitle",flowName);
            /*$.ajax({
                url: '../slim_ecoman/index.php/flowCompanies_json_test?flowid='+index+'&IS3='+$('#IS_search2').combobox('getValue')+'&cmpny_id='+companyID,
                type: 'GET',
                dataType : 'json',
                //data: 'rowIndex='+rowData.id,
                success: function(data, textStatus, jqXHR) {
                  //console.warn('success text status-->'+textStatus);
                  //$('#tt_grid_dynamic3').datagrid('getPanel').panel("setTitle",flowName);
                  
                  
                  
                  /*$('#tt_grid_dynamic3').datagrid({  
                      loadMsg :'Please wait while loading...',
                      rownumbers: "true",
                      pagination: "true",
                      idField:'id',
                      singleSelect: true,
                      //
                      //url: '../slim_ecoman/index.php/flowCompanies_json_test?flowid='+index+'&IS3='+$('#IS_search2').combobox('getValue')+'&cmpny_id='+companyID,
                   });*/
                 // $('#tt_grid_dynamic3').datagrid('loadData', data);
                  //$('#tt_grid_dynamic3').datagrid('reload');
                  
                  /*var opts = $('#tt_grid_dynamic3').datagrid('options');
                    var pager = $('#tt').datagrid('getPager');
                    if(pgNum.value!='' && pgSize.value!='' ){ // pgNum and pgSize hidden variable tell the which page i am and row count respectively.
                          opts.pageNumber = pgNum.value;
                       opts.pageSize = pgSize.value;
                       pager.pagination({
                               pageNumber:pgNum.value,
                             showPageList:false
                        });
                    }*/
                  
                    
                  
               /* },
                error: function(jqXHR , textStatus, errorThrown) {
                  console.warn('error text status-->'+textStatus);
                  //console.warn(jqXHR);
                }
            }); */
        }
        
        function getCompanyFlows(index,companyName) {
            
            $('#tt_grid_dynamic2').datagrid('getPanel').panel("setTitle",companyName);
            $('#tt_grid_dynamic2').datagrid({  
                loadMsg :'Please wait while loading...',
                rownumbers: "true",
                pagination: "true",
                url:'../../../slim_ecoman/index.php/companyFlows_json_test?companyid='+index+'&IS2='+$('#IS_search2').combobox('getValue')
             });
            
            /*$.ajax({
                url: '../slim_ecoman/index.php/companyFlows_json_test?companyid='+index+'&IS2='+$('#IS_search2').combobox('getValue'),
                type: 'GET',
                dataType : 'json',
                //data: 'rowIndex='+rowData.id,
                success: function(data, textStatus, jqXHR) {
                  //console.warn('success text status-->'+textStatus);
                  $('#tt_grid_dynamic2').datagrid('loadData', data);
                  
                  $('#tt_grid_dynamic2').datagrid('getPanel').panel("setTitle",companyName);
                  $('#tt_grid_dynamic2').datagrid({  
                      loadMsg :'Please wait while loading...',
                      rownumbers: "true",
                      pagination: "true",
                      url:'../slim_ecoman/index.php/companyFlows_json_test?companyid='+index+'&IS2='+$('#IS_search2').combobox('getValue')
                   });
                  
                  
                },
                error: function(jqXHR , textStatus, errorThrown) {
                  console.warn('error text status-->'+textStatus);
                  //console.warn(jqXHR);
                }
            }); */
        }
        
        function beginFlowPotential() {
            //var bos = array('');
            $('#tt_grid_dynamic3').datagrid('loadData',[]);
            $('#tt_grid_dynamic3').datagrid('loading');
            if($('#tt_grid_dynamic2').datagrid('getSelections').length==1) {
                //console.warn($('#tt_grid_dynamic2').datagrid('getSelections')[0].id);
                getFlowCompanies($('#tt_grid_dynamic2').datagrid('getSelections')[0].id, $('#tt_grid_dynamic2').datagrid('getSelections')[0].flow, $('#tt_grid2').datagrid('getSelections')[0].id);
            }else if($('#tt_grid_dynamic2').datagrid('getSelections').length>1){
                $.messager.alert('Only one flow at a time','Please select only one flow!','warning');
            } else {
                $.messager.alert('Pick a company','Please select  flow!','warning');
            }
        }
        
        
        function beginISPotential() {
            //var bos = array('');
            $('#tt_grid_dynamic2').datagrid('loading');
            $('#tt_grid_dynamic3').datagrid('loading');
            $('#tt_grid_dynamic2').datagrid('loadData',[]);
            $('#tt_grid_dynamic3').datagrid({  
                    url: '',
                   });
            $('#tt_grid_dynamic3').datagrid('loadData',[]);
            
            $('#tt_grid_dynamic3').datagrid('getPanel').panel('setTitle','Companies by specific flow');
            if($('#tt_grid2').datagrid('getSelections').length==1) {
                //console.warn($('#tt_grid2').datagrid('getSelections')[0].id);
                getCompanyFlows($('#tt_grid2').datagrid('getSelections')[0].id, $('#tt_grid2').datagrid('getSelections')[0].company);
            }else if($('#tt_grid2').datagrid('getSelections').length>1){
                $.messager.alert('Only one company at a time','Please select only one company!','warning');
            } else {
                $.messager.alert('Pick a company','Please select  company!','warning');
            }
        }
        
        function getTreeRoots() {
            var treeRoots = $('#tt_tree2').tree("getRoots");
            console.warn(treeRoots);
            $.each(treeRoots, function( index, obj ) {
                console.warn('getTreeRoots object id-->'+obj.id);
                
                obj.checked = true;
                console.warn('getTreeRoots object checked?-->'+obj.checked);
                
              });
              //$('#tt_tree2').tree("check",treeRoots[1]);
        }
        

	$(function() {
          
        var treeValue;
        $("#tt_tree2").tree({
                    onCheck: function(node, checked) {
                        //console.warn('oncheck event node id -->'+node.id);
                        //console.warn('oncheck event node id -->'+node.text);
                        if(checked) {
                            //console.warn('oncheck event checked -->'+node.text);
                            //console.warn(node.attributes.notroot);
                            //$('#tt_grid2').datagrid("showColumn",node.text.toLowerCase());
                            //$.inArray( 5 + 5, [ "8", "9", "10", 10 + "" ] );
                            
                            if(node.attributes.notroot) {
                                //$('#tt_grid').datagrid("showColumn",node.text.toLowerCase());
                                $('#tt_grid2').datagrid("showColumn",node.text);
                            }
                            if(node.children) {
                                $.each(node.children, function( index, obj ) {
                                //$('#tt_grid').datagrid("showColumn",obj.text.toLowerCase());
                                $('#tt_grid2').datagrid("showColumn",obj.text);
                                //console.warn(node.children);
                              });
                            }
                        } else {
                            //console.warn('oncheck event not checked -->'+node.text);
                            //$('#tt_grid2').datagrid("hideColumn",node.text.toLowerCase());
                            if(node.attributes.notroot) {
                                //$('#tt_grid').datagrid("hideColumn",node.text.toLowerCase());
                                $('#tt_grid2').datagrid("hideColumn",node.text);
                            }
                            if(node.children) {
                                $.each(node.children, function( index, obj ) {
                                //$('#tt_grid').datagrid("hideColumn",obj.text.toLowerCase());
                                $('#tt_grid2').datagrid("hideColumn",obj.text);
                                //console.warn(node.children);
                              });
                            }
                        }
                    },
                    onClick: function(node){
                    var parentnode=$("#tt_tree2").tree("getParent", node.target);
                    var roots=$("#tt_tree2").tree("getRoots");
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
                    if(node.state==undefined) {
                            //alert("bulu");
                            var de=parentnode.text;
                            var test_array=de.split("/");
                            //alert(test_array[1]);
                            treeValue=test_array[1];
                    } else {
                            treeValue=parentnode.text;
                    }
    
                    var imagepath=parentnode.text+"/"+node.text;
                },
                onExpand: function(node){
                    //alert("onExpand");
                    var root=$("#tt_tree2").tree("getRoot");
                    //alert("root text-->"+root.text);
                    var parent=$("#tt_tree2").tree("getParent",node.target);
                    if(parent) {
                        //alert("parent text-->"+parent.text);
                        //console.warn(node.id);
                        var nodes = $('#tt_tree2').tree('getChecked');
                        var s = '';
                        var num = '';
                        for(var i=0; i<nodes.length; i++){
                            if (s != '') s += ',';
                            s += nodes[i].text;
                            if (num != '') num += ',';
                            num += nodes[i].id;
                        }
                        //alert(s);
                        //console.warn(s);
                        //console.warn(num);

                    }else {
                        treeValue=node.text;
                        var nodeId = node.id;
                        //console.warn(node.id);
                        
                        
                        //alert(treeValue);
                        /*
                        var roots=$("#tt_tree2").tree("getRoots");
                        $(roots).each(function(index){
                            if(node.text!=roots[index].text) {
                            $("#tt_tree2").tree("collapse", roots[index].target);
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
                onCollapse: function(node){
                    //alert("onCollapse");
                    var root=$("#tt_tree2").tree("getRoot");
                    //alert("root text-->"+root.text);
                    var parent=$("#tt_tree2").tree("getParent",node.target);
                    if(parent) {
                        //alert("parent text-->"+parent.text);
                    }else {
                        /*
                        console.warn("root eleman id-->"+node.id);
                        console.warn("root eleman text-->"+node.text);
                        */
                        var nodeId = node.id;
                        var selections = $('#tt_grid2').datagrid("getSelections");
                        for(var i=0; i<selections.length; i++){
                            //console.warn(selections[i].company);
                        }
                        //console.warn(selections);

                    }
                    
                },
                onDblClick: function(node){
                //alert("onDblClick");
                var deneme="test";
                    var parent=$("#tt_tree2").tree("getParent",node.target);
                    if(parent) {
                    
                    } else {
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
            
   
    $('#tt_tree2').tree({
        
        //url : '../slim_ecoman/index.php/flowsManual',
        url : '../../../slim_ecoman/index.php/flows',
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
            {field:'flowtype',title:'I/O',width:100}
        ]],
         //rownumbers: "true",
         //pagination: "true",
         idField:'id',
         singleSelect:true,
         collapsible:true,
         fitColumns : true,
         toolbar:'#tb2',
         //width : 700
         //url : '../slim_ecoman/index.php/companyFlows'
    });
    
    $('#tt_grid_dynamic3').datagrid({
        columns:[[
            {field:'company',title:'Company',width:100},
            {field:'qntty',title:'Quantity',width:100},
            {field:'unit',title:'Unit',width:100},
            {field:'quality',title:'Quality',width:100},
            {field:'flowtype',title:'I/O',width:100}
        ]],
         rownumbers: "true",
         pagination: "true",
         idField:'id',
         singleSelect:true,
         collapsible:true,
         fitColumns : true,
         toolbar:'#tb3',
         //width : 500
         //url : '../slim_ecoman/index.php/companyFlows'
    });
    
    $('#tt_grid_dynamic4').datagrid({
        columns:[[
            {field:'company1',title:'Company',width:100},
            {field:'qntty1',title:'Quantity',width:100},
            {field:'company2',title:'Company',width:100},
            {field:'qntty2',title:'Quantity',width:100},
            {field:'flow',title:'Flow',width:100},
            //{field:'quality',title:'Quality',width:100},
            {field:'flowtype',title:'I/O',width:100},
            {field:'action',title:'Action',width:150,align:'center',
                formatter:function(value,row,index){
                    if (row.editing){
                        var s = '<a href="#" onclick="saverow(this)">Save</a> ';
                        var c = '<a href="#" onclick="cancelrow(this)">Cancel</a>';
                        return s+c;
                    } else {
                        //var e = '<a href="#" onclick="editrow(this)">Edit</a> ';
                        //var d = '<a href="#" onclick="deleteISPotential(this)" >Delete</a>';
                         var d = '<button class="btn btn-mini rn_btnDelete" onclick="deleteISPotential(this)">Delete</button>';
                        //return e+d;
                        return d;
                    }
                }
            }
        ]],
         //rownumbers: "true",
         //pagination: "true",
         idField:'id',
         singleSelect:true,
         collapsible:true,
         fitColumns : true,
         toolbar:'#tb4',
         onDblClickRow: function(rowIndex, rowData){
                      //alert(rowIndex);
                      console.warn(rowData); 
              }
         //width : 500
         //url : '../slim_ecoman/index.php/companyFlows'
    });
    
    
    /**
    *  @todo buras� dinamik kolon yap�s� i�in denenecek
     */
    $.ajax({
        url: '../../../slim_ecoman/index.php/columnflows_json_test',
        type: 'GET',
        dataType : 'json',
        //data: 'rowIndex='+rowData.id,
        success: function(data, textStatus, jqXHR) {
          console.warn('success text status-->'+textStatus);
          
          $('#tt_grid2').datagrid({
                singleSelect:true,
                /*ctrlSelect:true,*/
                collapsible:true,
                /*url:'datagrid_data1.json',*/
                url:'../../../slim_ecoman/index.php/companies_json_test2',
                method:'get',
                idField:'id',
                toolbar:'#tb',
                remoteSort:true,
                multiSort:false,
                //loadMsg :'Please wait while loading...',
                rownumbers: "true",
                pagination: "true",
                //height : 700,
                remoteFilter: true,
                columns:[
                        data
                    ],
                onDblClickRow: function(rowIndex, rowData){
                      alert(rowIndex);
                      console.warn(rowData);
                      $.ajax({
                          url: '../../../slim_ecoman/index.php/flows',
                          type: 'GET',
                          dataType : 'json',
                          data: 'rowIndex='+rowData.id,
                          success: function(data, textStatus, jqXHR) {
                            console.warn('success text status-->'+textStatus);
                            //console.warn(jqXHR);

                          },
                          error: function(jqXHR , textStatus, errorThrown) {
                            console.warn('error text status-->'+textStatus);
                            //console.warn(jqXHR);
                          }
                      }); 
              }

        });
        
        var gridColumns = $('#tt_grid2').datagrid('getColumnFields');
        
        var arrayFilter = [];
        var arrayFirst =[];
        $.each(gridColumns, function( index, obj ) {
                                arrayFirst =[];
                                /*console.warn('index-->'+index+'');
                                console.warn('object-->'+obj+'');
                                console.warn('lower case-->'+obj.toLowerCase()+'');*/
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
                /*singleSelect:false,
                ctrlSelect:true,*/
                collapsible:true,
                /*url:'datagrid_data1.json',*/
                url:'../../../slim_ecoman/index.php/ISScenarios',
                method:'get',
                idField:'id',
                /*toolbar:'#tb',*/
                remoteSort:false,
                multiSort:false,
                loadMsg :'Please wait while loading...',
                rownumbers: "true",
                pagination: "true",
                //remoteFilter: true,
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
          //console.warn(jqXHR);
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


