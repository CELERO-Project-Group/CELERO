<?php 
	$uri = service('uri');
?>
<script type="text/javascript" src="<?= base_url('assets/js/easy-ui-1.4.2.js'); ?>"></script>
<script src="https://d3js.org/d3.v3.min.js"></script>
<script type="text/javascript">

	var temp_array = new Array();
	var temp_index = 0;
	var ep_alt_temp_array = new Array();
	var ep_alt_temp_index = 0;
	var ep_ust_temp_array = new Array();
	var ep_ust_temp_index = 0;
	var cost_array = new Array();
	var cost_array_clone = new Array();
	var cost_index = 0;
	var index_array = new Array();
	var list=new Array;
	var veri = 0;
	var timer = null;

	function cost_ep_value(prcss_id,process_adet){
		$.ajax({
			type: "GET",
			dataType: 'json',
			url: '<?= base_url('cpscoping/cost_ep'); ?>/'+prcss_id+'/'+<?= $uri->getSegment(2);?>+'/'+<?= $uri->getSegment(3); ?>,
			success: function(data){
				list.push(data);
				//datagrid'in içini doldurma
				$('#dg').datagrid('loadData', list);
				veri = veri +1;
				if(veri == process_adet){
					tuna_graph(list);
					$('#graph_text').text("");
					clearTimeout(timer);
				}
				else{
					$('#graph_text').text("<?= lang('cpscopinggraphinfo2'); ?> ("+veri+"/"+process_adet+")");
	       	clearTimeout(timer);
	       	timer = setTimeout(function() { tuna_graph(list); 					
	       		$('#graph_text').text(""); 
	       	}, 7000);
				}
			}

		});
	};

	function is_candidate(id){
		var buton_durum = 0;
		$(document).ready(function () {
			$.ajax({
		     	type: "POST",
		     	dataType:'json',
			  	url: '<?= base_url('cpscoping/is_candidate_control'); ?>/'+id,
		      	success: function(data)
		      	{
		      		if(!(data.control == 1)){
		      			$("#"+id).removeClass();
		    			$("#"+id).addClass("btn btn-success btn-xs pull-right");
		    			$("#"+id).html("<?= lang('selected'); ?>");
		    			buton_durum = 1;
		    		}else{
		    			$("#"+id).removeClass();
		    			$("#"+id).addClass("btn btn-default btn-xs pull-right");
		    			$("#"+id).html("<?= lang('dropped'); ?>");
		    			buton_durum = 0;
		    		}
		    		$.ajax({
				     	type: "POST",
				     	dataType:'json',
					  	url: '<?= base_url('cpscoping/is_candidate_insert'); ?>/'+id+'/'+buton_durum,
				    });
		      	}
		    });
	  	});
	};

	function open_document(id){
		alert(id);
	};
</script>
		<div class="col-md-12" style="margin-bottom: 10px;">
			<a class="btn btn-inverse btn-sm" href="<?= base_url('kpi_calculation/'.$uri->getSegment(2).'/'.$uri->getSegment(3)); ?>"><?= lang("Validation.gotokpi"); ?></a>
			<a href="<?= base_url('new_flow/'.$uri->getSegment(3)); ?>/" class="btn btn-inverse btn-sm" id="cpscopinga"><?= lang("Validation.gotodataset"); ?></a>
		</div>
		<div class="col-md-12" id="sol4">
			<p><?= lang("Validation.cpscopingheading1"); ?></p>
			<div class="label label-info" id="graph_text"></div>
		  	<div id="rect-demo-ana" style="border:2px solid #f0f0f0;">
		    	<div id="rect-demo"></div>
	    	</div>
		</div>
		<div class="col-md-12">
			<hr>
			<p><?= lang("Validation.cpscopingheading2"); ?></p>
			<table class="table table-bordered">
			<tr>
			<th style="width:150px;"><?= lang("Validation.inputflows"); ?></th>
			<th style="width:150px;text-align:center;"><?= lang("Validation.total"); ?></th>
			<?php $deneme_arrayi = array(); $tekrarsiz = array(); $tekrarsiz[-1] = "0"; $count = 0; $process_adet=0; ?>
			<?php foreach ($allocation as $a): ?>
			<?php
			if(!empty($a['prcss_name'])){
				$degisken = 1;
				$deneme_arrayi[$count] = $a['prcss_name'];
				$count++;
				for ($i=0; $i < $count-1; $i++) {
					if($deneme_arrayi[$i] == $a['prcss_name']){
					$degisken = 0;
					break;
					}
				}
				if($degisken == 1){
					$process_adet++;
					echo "<th style='width:200px;text-align:center;'>".$a['prcss_name']."</th>";
					$tekrarsiz[$process_adet-1] = $a['prcss_id'];
				}
			}
			?>
			<?php endforeach ?>
			</tr>
			<?php
				$count = 0; $deneme_array = array(); $flow_type_array = array();
				foreach ($allocation as $a):
					if(!empty($a['flow_name'])):
					$degisken = 1;
					$deneme_array[$count] = $a['flow_name'];
					$flow_type_array[$count] = $a['flow_type_id'];
					$count++;
					for ($i=0; $i < $count-1; $i++) {
						if($deneme_array[$i] == $a['flow_name'] && sizeof($deneme_array) > 1 && $flow_type_array[$i] == $a['flow_type_id']){
							$degisken = 0;
							break;
						}
					}

					if($degisken == 1 && $a['flow_type_id'] == 1): ?>
					<tr>
						<td style="width:200px;">
							<b><?= $a['flow_name']; ?></b>
							<?php if ($active[$a['allocation_id']] == 0): ?>
								<button class="btn btn-default btn-xs pull-right" id="<?= $a['allocation_id']; ?>" onclick="is_candidate(<?= $a['allocation_id'];?>)">
									<?= lang("Validation.selectascandidate"); ?>
								</button>
							<?php else: ?>
								<button class="btn btn-success btn-xs pull-right" id="<?= $a['allocation_id']; ?>" onclick="is_candidate(<?= $a['allocation_id'];?>)"><?= lang("Validation.selectedcandidate"); ?>
								</button>
							<?php endif ?>

						</td>
						<?php for ($t=0; $t < $process_adet+1; $t++): ?>
							<td style="padding:0px !important;">
								<div class="<?= $a['flow_id'].''.$tekrarsiz[$t-1]; ?>1">
									<?php
										$bak = $a['flow_id'].'-'.$tekrarsiz[$t-1].'-1';
										if(!empty($allocationveri[$bak])):
									?>
										<?php if(!empty($allocationveri[$bak]['error_amount'])): ?>
											<table style="font-size:11px;width:100%;text-align:center;" frame="void">
												<tr><td class="table-numbers" style="width:70%"><?= number_format($allocationveri[$bak]['amount'], 0, ".", "'"); ?>
												</td>
												<td style="text-align:right;">
												 <?= $allocationveri[$bak]['unit_amount']; ?> <span class="label label-info"><?= $allocationveri[$bak]['error_amount']; ?>%</span> </td></tr>
												<tr><td class="table-numbers" style="width:70%"><?= number_format($allocationveri[$bak]['cost'], 0, ".", "'"); ?>
												</td>
												<td style="text-align:right;">
												<?= $allocationveri[$bak]['unit_cost']; ?> <span class="label label-info"><?= $allocationveri[$bak]['error_cost']; ?>%</span></td></tr>
												<tr><td class="table-numbers" style="width:70%"><?= number_format($allocationveri[$bak]['env_impact'], 0, ".", "'"); ?>
												</td>
												<td style="text-align:right;">
												<?= $allocationveri[$bak]['unit_env_impact']; ?> <span class="label label-info"><?= $allocationveri[$bak]['error_ep']; ?>%</span></td></tr>
											</table>
										<?php else: ?>
											<table style="font-size:11px; width: 100%; text-align:center;" frame="void">
												<tr><td class="table-numbers" style="width:80%"><?=  number_format($allocationveri[$bak]['amount'], 0, ".", "'"); ?> 
												</td>
												<td style="text-align:right;">
												<?= $allocationveri[$bak]['unit_amount']; ?> </td></tr>
												<tr><td class="table-numbers" style="width:80%"><?= number_format($allocationveri[$bak]['cost'], 0, ".", "'"); ?> 
												</td>
												<td style="text-align:right;">
												<?= $allocationveri[$bak]['unit_cost']; ?></td></tr>
												<tr><td class="table-numbers" style="width:80%"><?= number_format($allocationveri[$bak]['env_impact'], 0, ".", "'"); ?> 
												</td>
												<td style="text-align:right;">
												<?= $allocationveri[$bak]['unit_env_impact']; ?></td></tr>
											</table>
										<?php endif ?>
										
									<?php	else: ?>
										
									<?php	endif ?>
								</div>
							</td>
						<?php endfor ?>
					</tr>

				<?php endif ?>
				<?php endif ?>
				<?php endforeach ?>
			</table>

			<!-- Output Table -->
			<table class="table table-bordered">
			<tr>
			<th style="width:150px;"><?= lang("Validation.outputflows"); ?></th>
			<th style="width:150px;text-align: center;"><?= lang("Validation.total"); ?></th>
			<?php $deneme_arrayi = array(); $tekrarsiz = array(); $tekrarsiz[-1] = "0"; $count = 0; $process_adet=0; ?>
			<?php foreach ($allocation as $a): ?>
			<?php
			if(!empty($a['prcss_name'])){
				$degisken = 1;
				$deneme_arrayi[$count] = $a['prcss_name'];
				$count++;
				for ($i=0; $i < $count-1; $i++) {
					if($deneme_arrayi[$i] == $a['prcss_name']){
					$degisken = 0;
					break;
					}
				}
				if($degisken == 1){
					$process_adet++;
					echo "<th style='width:200px;text-align:center;'>".$a['prcss_name']."</th>";
					$tekrarsiz[$process_adet-1] = $a['prcss_id'];
				}
			}
			?>
			<?php endforeach ?>
			</tr>
			<?php
				$count = 0; $deneme_array = array();
				foreach ($allocation as $a):
					if(!empty($a['flow_name'])){
					$degisken = 1;
					$deneme_array[$count] = $a['flow_name'];
					$count++;
					for ($i=0; $i < $count-1; $i++) {
						if($deneme_array[$i] == $a['flow_name'] && sizeof($deneme_array) > 1){
							$degisken = 0;
							break;
						}
					}
					if($degisken == 1){
						$id = 0;
						foreach ($allocation_output as $a_output) {
							if(!empty($a_output['flow_name'])){
								if($a_output['flow_name'] == $a['flow_name']){
									$id = $a_output['allocation_id'];
								}
							}
							
						}
						if($id == 0){
							continue;
						}

							?>
					<tr>
						<td style="width:200px;">
							<b><?= $a['flow_name']; ?></b>
							<?php
							if($id != 0){
							if ($active[$id] == 0): ?>
								<button class="btn btn-default btn-xs pull-right" id="<?= $id; ?>" onclick="is_candidate(<?= $id;?>)"><?= lang("Validation.selectascandidate"); ?>
								</button>
							<?php else: ?>
								<button class="btn btn-success btn-xs pull-right" id="<?= $id; ?>" onclick="is_candidate(<?= $id;?>)"><?= lang("Validation.selectedcandidate"); ?>
								</button>
							<?php endif ?>

							<?php } ?>

						</td>
						<?php for ($t=0; $t < $process_adet+1; $t++): ?>
							<script type="text/javascript">
								//yazdir(<?= $a['flow_id']; ?>,<?= $tekrarsiz[$t-1]; ?>,2);
							</script>
							<td style="padding:0px !important;">
								<div class="<?= $a['flow_id'].''.$tekrarsiz[$t-1]; ?>2">
									<?php
										$bak = $a['flow_id'].'-'.$tekrarsiz[$t-1].'-2';
										if(!empty($allocationveri[$bak])):
									?>
										<?php if(!empty($allocationveri[$bak]['error_amount'])): ?>
											<table style="font-size:11px; width: 100%; text-align:center;" frame="void">
												<tr><td class="table-numbers" style="width:70%"><?= number_format($allocationveri[$bak]['amount'], 0, ".", "'"); ?> </td>
												<td style="text-align:right">
												<?= $allocationveri[$bak]['unit_amount']; ?> <span class="label label-info"><?= $allocationveri[$bak]['error_amount']; ?>%</span> </td></tr>
												<tr><td class="table-numbers" style="width:70%"><?= number_format($allocationveri[$bak]['cost'], 0, ".", "'"); ?> </td>
												<td style="text-align:right">
												<?= $allocationveri[$bak]['unit_cost']; ?> <span class="label label-info">	<?= $allocationveri[$bak]['error_cost']; ?>%</span></td></tr>
												<tr><td class="table-numbers" style="width:70%"><?= number_format($allocationveri[$bak]['env_impact'], 0, ".", "'"); ?> </td>
												<td style="text-align:right">
												<?= $allocationveri[$bak]['unit_env_impact']; ?> <span class="label label-info"><?= $allocationveri[$bak]['error_ep']; ?>%</span></td></tr>
											</table>
										<?php else: ?>
											<table style="font-size:11px; width: 100%; text-align:center;" frame="void">
												<tr><td class="table-numbers" style="width:80%"> <?= number_format($allocationveri[$bak]['amount'], 0, ".", "'"); ?> </td>
												<td style="text-align:right;"> <?= $allocationveri[$bak]['unit_amount']; ?> </td></tr>
												<tr><td class="table-numbers" style="width:80%"><?= number_format($allocationveri[$bak]['cost'], 0, ".", "'"); ?> </td>
												<td style="text-align:right;"> <?= $allocationveri[$bak]['unit_cost']; ?></td></tr>
												<tr><td class="table-numbers" style="width:80%"><?= number_format($allocationveri[$bak]['env_impact'], 0, ".", "'"); ?> </td>
												<td style="text-align:right;"><?= $allocationveri[$bak]['unit_env_impact']; ?></td></tr>
											</table>
										<?php endif ?>
										<?php //print_r($allocationveri[$bak]); ?>
									<?php	else: ?>
										<?php //echo $bak; ?>
									<?php	endif ?>
								</div>
							</td>
						<?php endfor ?>
					</tr>

				<?php } ?>
				<?php } ?>
				<?php endforeach ?>
			</table>

			<hr>
			<?php for($i = 0 ; $i < $process_adet ; $i++): ?>
				<script type="text/javascript">
					cost_ep_value(<?= $tekrarsiz[$i]; ?>,<?= $process_adet; ?>);
				</script>
			<?php endfor ?>


			<table id="dg" class="easyui-datagrid"
			    data-options="
			        iconCls: 'icon-edit',
			        singleSelect: true,
			        toolbar: '#tb',
			        method: 'get',
			        fitColumns: true,
			        onClickRow: onClickRow
			    ">
				<thead>
				    <tr>
				        <th data-options="field:'prcss_name',align:'center',width:150"><?= lang("Validation.process"); ?></th>
				        <th data-options="field:'ep_def_value',align:'right',width:80" formatter="formatPrice"><?= lang("Validation.ep"); ?></th>
				        <th data-options="field:'ep_value_alt',align:'right',width:100" formatter="formatPrice"><?= lang("Validation.lowerepvalue"); ?></th>
				        <th data-options="field:'ep_value_ust',align:'right',width:100" formatter="formatPrice"><?= lang("Validation.upperepvalue"); ?></th>
				        <th data-options="field:'cost_def_value',align:'right',width:100" formatter="formatPrice"><?= lang("Validation.cost"); ?></th>
				        <th data-options="field:'cost_value_alt',align:'right',width:110" formatter="formatPrice"><?= lang("Validation.lowercostvalue"); ?></th>
				        <th data-options="field:'cost_value_ust',align:'right',width:110" formatter="formatPrice"><?= lang("Validation.uppercostvalue"); ?></th>
				        <th data-options="field:'comment',width:200,align:'center',editor:'text'"><?= lang("Validation.comments"); ?></th>
				    </tr>
				</thead>
			</table>
    <div id="tb">
    		<p style="float:left;"><?= lang("Validation.cpscopingheading3"); ?></p>
        <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-save',plain:true" onclick="accept()"><?= lang("Validation.saveallchanges"); ?></a>
        <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-undo',plain:true" onclick="reject()"><?= lang("Validation.cancelallchanges"); ?></a>
    </div>
    <script type="text/javascript">
    function formatPrice(input){
    	console.log(input);
    	if (input !== undefined){
    		input = input.toFixed(2);
    	}
  		    var output = input;
			    if (parseFloat(input)) {
			        input = new String(input); // so you can perform string operations
			        var parts = input.split("."); // remove the decimal part
			        parts[0] = parts[0].split("").reverse().join("").replace(/(\d{3})(?!$)/g, "$1'").split("").reverse().join("");
			        output = parts.join(".");
			    }
	    return output;
		}
		</script>
    <script type="text/javascript">
        var editIndex = undefined;
        function endEditing(){
            if (editIndex == undefined){return true}
            if ($('#dg').datagrid('validateRow', editIndex)){
                $('#dg').datagrid('endEdit', editIndex);
                editIndex = undefined;
                return true;
            } else {
                return false;
            }
        }
        function onClickRow(index){
            if (editIndex != index){
                if (endEditing()){
                    $('#dg').datagrid('selectRow', index)
                            .datagrid('beginEdit', index);
                    editIndex = index;
                } else {
                    $('#dg').datagrid('selectRow', editIndex);
                }
            }
        }
        function accept(){
            if (endEditing()){
            	var rows = $('#dg').datagrid('getRows');
        			var prjct_id = <?= $uri->getSegment(2); ?>;
							var cmpny_id = <?= $uri->getSegment(3); ?>;
							$("#alerts").html("");
							$("#alerts").fadeIn( "fast" );
							$.each(rows, function(i, row) {
							  $('#dg').datagrid('endEdit', i);
							  /* var url = row.isNewRecord ? 'test.php?savetest=true' : 'test.php?updatetest=true'; */
							  var url = '../../comment_save/'+cmpny_id+'/'+row.prcss_id;
							  $.ajax(url, {
							      type:'POST',
							      dataType:'json',
							      data:row,
					          success: function(data, textStatus, jqXHR) {
					          	console.log(row.prcss_id);
					          	console.log(data);
					          	//alert(data);
					          	$("#alerts").append(data);
										},
								    error: function(jqXHR, textStatus, errorThrown) {
										  console.log(textStatus, errorThrown);
										}
							  });
							});
							$("#alerts").delay(5000).fadeOut( "fast" );

            }
        }
        function reject(){
            $('#dg').datagrid('rejectChanges');
            editIndex = undefined;
        }
        function getChanges(){
            var rows = $('#dg').datagrid('getChanges');
            alert(rows.length+' rows are changed!');
        }
    </script>
    <div id="alerts" style="margin-top: 20px;font-size: 13px;color: darkgrey;"></div>



		</div>
<script type="text/javascript">

	function tuna_graph(list){
	//console.log(list);

	//Tuna Graph
	var data = list;
	//console.log(data);

	var margin = {
	            "top": 10,
	            "right": 30,
	            "bottom": 300,
	            "left": 80
	        };
	var width = $('#sol4').width()-110;
	var height = 400;

	// Set the scales
  var x = d3.scale.linear()
      .domain([d3.min(data, function(d) { return d.cost_value_alt; })-1000, d3.max(data, function(d) { return d.cost_value_ust+100; })])
      .range([0,width]).nice();

  var y = d3.scale.linear()
      .domain([d3.min(data, function(d) { return d.ep_value_alt; })-100, d3.max(data, function(d) { return d.ep_value_ust; })])
      .range([height, 0]).nice();

  var xAxis = d3.svg.axis().scale(x).orient("bottom");
  var yAxis = d3.svg.axis().scale(y).orient("left");

	// var color = d3.scale.category20();
	// Create the SVG 'canvas'
  var svg = d3.select("#rect-demo-ana").append("svg")
    .attr("class", "chart")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom).append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.right + ")");

  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  svg.append("g")
    .attr("class", "y axis")
    .call(yAxis);

	//x axis label
	svg.append("text")
		.attr("transform", "translate(" + (width / 2) + " ," + (height + margin.bottom - 255) + ")")
		.style("text-anchor", "middle")
		.text("Cost Value");

	//y axis label
	svg.append("text")
		.attr("transform", "rotate(-90)")
		.attr("y", 0 - margin.left)
		.attr("x", 0 - (height / 2))
		.attr("dy", "1em")
		.style("text-anchor", "middle")
		.text("Ep Value");

	svg.selectAll("rect").
	  data(data).
	  enter().
	  append("svg:rect").
	  attr("x", function(datum,index) { return x(datum.cost_value_alt); }).
	  attr("y", function(datum,index) { return y(datum.ep_value_ust); }).
	  attr("height", function(datum,index) { return Math.abs(y(datum.ep_value_alt))-Math.abs(y(datum.ep_value_ust)); }).
	  attr("width", function(datum, index) { 
	  	//console.log("tuna");
	  	//console.log(Math.abs(x(datum.cost_value_ust)-x(datum.cost_value_alt)));
	  	return Math.abs(x(datum.cost_value_ust)-x(datum.cost_value_alt)); }).
	  attr("fill",function(datum,index) { return datum.color; })
	  .style("opacity", '0.9')
  	.on("mouseover", function(datum,index){return tooltip.style("visibility", "visible").html("<span style='color:blue !important;'>"+datum.prcss_name+"</span><br>EP Range:"+datum.ep_value_alt+" - "+datum.ep_value_ust+"<br>Cost Range:"+datum.cost_value_alt+" - "+datum.cost_value_ust);})
		.on("mousemove", function(datum,index){return tooltip.style("top", (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px").html("<span style='color:blue !important;'>"+datum.prcss_name+"</span><br>EP Range: "+datum.ep_value_alt+" - "+datum.ep_value_ust+"<br>Cost Range: "+datum.cost_value_alt+" - "+datum.cost_value_ust);})
		.on("mouseout", function(){return tooltip.style("visibility", "hidden");});

		var tooltip = d3.select("body")
		.append("div")
		.style("position", "absolute")
		.style("z-index", "10")
		.style("visibility", "hidden")
		.style("background-color", "white")
		.style("padding", "10px")
		.style("border", "1px solid #d0d0d0")
		.style("border-radius", "2px")
		.style("font-size", "12px")
		.style("max-width", "300px")
		.style("color", "#444");

	// add legend
	var legend = svg.append("g")
	  .attr("class", "legend")
        //.attr("x", w - 65)
        //.attr("y", 50)
	  .attr("height", 100)
	  .attr("width", 100)
    .attr('transform', 'translate(-20,50)')

    legend.selectAll('rect')
      .data(data)
      .enter()
      .append("circle")
      .attr("r", 7)
      .attr("cx", 1)
      .attr("cy", function(d, i){ return 425 + (i *  20);})
	  	.style("fill", function(datum,index) { return datum.color; })
    	.style("opacity", '0.9')

    legend.selectAll('text')
      .data(data)
      .enter()
      .append("text")
	  .attr("x", 22)
	  .style("font-size", "12px")
    .attr("y", function(d, i){ return i *  20 + 429;})
	  .text(function(datum,index) { return datum.prcss_name; });

	  svg.call(
	  	d3.behavior.zoom()
	  	.x(x).y(y).on("zoom", zoom)
	  	);
 
		function zoom() {
		  svg.select(".x.axis").call(xAxis);
		  svg.select(".y.axis").call(yAxis);
		  svg.selectAll('rect').attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
		}

	}
</script>