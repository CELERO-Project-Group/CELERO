<?php
$uri = service('uri');
?>
<script type="text/javascript" src="<?= base_url('assets/js/easy-ui-1.4.2.js'); ?>"></script>
<?php if (!empty($kpi_values)): ?>
	<div class="row">
		<div class="col-md-12" style="margin-bottom: 10px;">
			<a href="<?= base_url('cpscoping'); ?>/" class="btn btn-inverse btn-sm" id="cpscopinga">
				<?= lang("Validation.gotocpscoping"); ?>
			</a>
			<a href="<?= base_url('new_flow/' . $uri->getSegment(3)); ?>/" class="btn btn-inverse btn-sm" id="cpscopinga">
				<?= lang("Validation.gotodataset"); ?>
			</a>
		</div>
	</div>

	<div class="row">
		<div class="col-md-12" id="8lik">
			<table id="dg" class="easyui-datagrid" data-options="
					iconCls: 'icon-edit',
					singleSelect: false,
					ctrlSelect: true,
					toolbar: '#tb',
					url: '<?= base_url("kpi_json/" . $uri->getSegment(2) . '/' . $uri->getSegment(3)); ?>',
					method: 'get',
					fitColumns: true,
					nowrap: false,
					rownumbers: true,
					onClickRow: onClickRow
				">
				<thead>
					<tr>
						<th data-options="field:'allocation_name',align:'left',width:200">
							<?= lang("Validation.allocation"); ?>
						</th>
						<th data-options="field:'flow_name',align:'center',width:110">Flow</th>
						<th data-options="field:'flow_type_name',align:'center',width:80">Flow Type</th>
						<th data-options="field:'kpi',align:'right',width:100">KPI</th>
						<th
							data-options="field:'benchmark_kpi',width:100,align:'right',editor:{type:'numberbox',options:{precision:2}}">
							<?= lang("Validation.benchmark"); ?><span style="color:red;">*
						</th>
						<th data-options="field:'unit_kpi',align:'right',width:80">
							<?= lang("Validation.kpiunit"); ?>
						</th>
						<th data-options="field:'kpidef',align:'center',width:130">
							<?= lang("Validation.kpidef"); ?>
						</th>
						<th data-options="field:'best_practice',width:200,align:'center',editor:'text'">
							<?= lang("Validation.CBoptionname"); ?> <span style="color:red;">*
						</th>
						<th data-options="field:'description',width:300,align:'left',
						editor:{
								type:'textbox',
								options:{
									multiline:true,
									prompt:'Describe your cost benefit option...',
									height:100
								}
							}">
							<?= lang("Validation.description"); ?>
						</th>
						<th data-options="field:'option',width:80,align:'center',editor:{type:'checkbox',options:{on:'Option',off:'Not An Option'}}"
							formatter="formatOption">
							<?= lang("Validation.isoption"); ?>?
						</th>
						<th data-options="field:'allocation_id',width:100,align:'center'" formatter="formatDetail">
							<?= lang("Validation.editallocation"); ?>
						</th>
					</tr>
				</thead>
			</table>
			<div id="tb">
				<p style="float:left;">
					<?= lang("Validation.kpiheading1"); ?>
				</p>
				<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-save',plain:true"
					onclick="accept()">
					<?= lang("Validation.saveallchanges"); ?>
				</a>
				<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-undo',plain:true"
					onclick="reject()">
					<?= lang("Validation.cancelallchanges"); ?>
				</a>
			</div>
			<hr>
		</div>
	</div>
	<div class="row content2">
		<div class="col-md-6">
			<p>
				<?= lang("Validation.kpiheading2"); ?>
			</p>
			<!-- 		<div class="label label-danger">After a save, you should reload the page to see updated graph.</div> -->
			<div id="chart_div" style="border:2px solid #f0f0f0;"></div>
		</div>
		<div class="col-md-6">
			<p><b>
					<?= lang("Validation.searchdocument"); ?>
				</b></p>
			<?= form_open_multipart('search_result/' . $uri->getSegment(2) . '/' . $uri->getSegment(3)); ?>
			<?= csrf_field(); ?>
			<input style="margin-bottom:10px;" type="text" class="form-control" id="search" placeholder="" name="search">
			</form>
			<hr>
			<p><b>
					<?= lang("Validation.documentupload"); ?>
				</b> <small>(
					<?= lang("Validation.allowedfiletypes") ?>)
				</small></p>
			<div class="form-group">
				<?php
				if (isset($error)) {
					echo "<div style=' color:#E74C3C;margin: 10px 0;padding: 15px;padding-bottom: 0;border: 1px solid;'>Error while uploading, please check file size or document type: " . $error . "</div>";
				} elseif ($success) {
					echo "<div style=' color:#2eb3e7;margin: 10px 0;padding: 15px;padding-bottom: 20;border: 1px solid;'>You have successfully uploaded a new file.</div>";
				}
				?>
				<?= form_open_multipart('cpscoping/file_upload/' . $uri->getSegment('2') . '/' . $uri->getSegment('3')); ?>
				<?= csrf_field(); ?>
				<input type="file" name="docuFile" id="docuFile"> <br />
				<input type="submit" class="btn btn-info btn-sm" value="<?= lang("Validation.savefile"); ?>">
				</form>
			</div>
			<hr>
			<p>
				<?= lang("Validation.uploadeddocument"); ?>
			</p>
			<table class="table table-bordered">
				<tr>
					<th>Index</th>
					<th>
						<?= lang("Validation.filename"); ?>
					</th>
					<th>
						<?= lang("Validation.manage"); ?>
					</th>
				</tr>
				<?php $sayac = 1;
				foreach ($cp_files as $file): ?>
					<tr>
						<td>
							<?= $sayac;
							$sayac++; ?>
						</td>
						<td>
							<a href="<?= base_url("assets/cp_scoping_files/" . $file['file_name']); ?>" id="<?= $file['id']; ?>"
								style="width:100%;background-color: Transparent;
										background-repeat:no-repeat;
										border: none;
										cursor:pointer;
										overflow: hidden;
										outline:none;">
								<?= $file['file_name']; ?>
							</a>
						</td>
						<td>
							<a onclick="return confirm('Are you sure?')"
								href="<?= base_url("cpscoping/file_delete/" . $file['file_name'] . "/" . $uri->getSegment(2) . "/" . $uri->getSegment(3)); ?>">
								<?= lang("Validation.delete"); ?>
							</a>
						</td>
					</tr>
				<?php endforeach ?>
			</table>
		</div>
	</div>
<?php else: ?>
	<div class="container">
		<div class="col-md-4"></div>
		<div class="col-md-4" style="margin-bottom: 10px; text-align:center;">
			<a class="btn btn-default btn-sm"
				href="<?= base_url('cpscoping/' . $uri->getSegment(2) . '/' . $uri->getSegment(3) . '/show'); ?>">Show CP
				Scoping
				Data</a>
			<p>There is nothing to display!</p>
		</div>
		<div class="col-md-4"></div>
	</div>
<?php endif ?>

<div class="modal fade" id="myModalsave" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="myModalLabel">
					<?= lang("Validation.savekpi") ?>
				</h4>
			</div>
			<div class="modal-body">
				<div id="alerts" style="margin-top: 20px;font-size: 13px;color: darkgrey;"></div>
				<br>
				<button type="button" id="saveButton" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true" disabled>
					<?= lang("Validation.saving"); ?>
				</button>
			</div>
			<div class="modal-footer"></div>
		</div>
	</div>
</div>



<!-- <script type="text/javascript" src="https://www.google.com/jsapi"></script> -->
<script>

	function formatDetail(value, row) {
		var href = '/cpscoping/edit_allocation/' + value;
		return '<a class="label label-info" href="' + href + '"><?= lang("Validation.edit"); ?></a>';
	}

	function formatOption(val, row) {
		if (val == "Option") {
			return '<span style="color:green;">(' + val + ')</span>';
		} else {
			return '<span style="color:darkred;">(' + val + ')</span>';
		}
	}
</script>
<script type="text/javascript">
	document.getElementById('saveButton').addEventListener('click', function () {

        this.classList.remove('disabled');
        window.location.href = "<?= base_url("kpi_calculation/". $uri->getSegment(2) . '/' . $uri->getSegment(3)) ?>";
    });

	var editIndex = undefined;
	function endEditing() {
		if (editIndex == undefined) { return true }
		if ($('#dg').datagrid('validateRow', editIndex)) {
			$('#dg').datagrid('endEdit', editIndex);
			editIndex = undefined;
			return true;
		} else {
			return false;
		}
	}
	function onClickRow(index) {
		if (editIndex != index) {
			if (endEditing()) {
				$('#dg').datagrid('selectRow', index)
					.datagrid('beginEdit', index);
				editIndex = index;
			} else {
				$('#dg').datagrid('selectRow', editIndex);
			}
		}
	}

	// 	async function accept() {
	//     if (endEditing()) {
	//         var rows = $('#dg').datagrid('getRows');
	//         var kpi_insert = <?= json_encode(base_url('kpi_insert/')); ?>;
	//         var prjct_id = <?= json_encode($uri->getSegment(2)); ?>;
	//         var cmpny_id = <?= json_encode($uri->getSegment(3)); ?>;

	//         $('#dg').datagrid('unselectAll');
	//         rows.forEach(async function (row, i) {
	//             var url = kpi_insert + '/' + prjct_id + '/' + cmpny_id + '/' + row['flow_id'] + '/' + row['flow_type_id'] + '/' + row['prcss_id'] + '/' + row['allocation_id'];
	//             try {
	//                 const response = await fetch(url, {
	//                     method: "PUT", // or 'PUT'
	//                     headers: {
	//                         "Content-Type": "application/json",
	//                     },
	//                     body: JSON.stringify(row),
	//                 });
	// 				console.log(response);
	//                 const result = await response.json();
	//                 console.log("Success:", result);
	//                 if (result.indexOf("red") >= 0) {
	//                     $('#dg').datagrid('selectRow', i);
	//                 } else {
	//                     // If no error, assume the response is HTML and insert it
	//                     insertInline(i + 1, result);
	//                 }
	//             } catch (error) {
	//                 console.error("Error:", error);
	//             }
	//         });
	//     }
	// }

	function accept() {
		if (endEditing()) {
			var rows = $('#dg').datagrid('getRows');
			var prjct_id = <?= $uri->getSegment(2); ?>;
			var cmpny_id = <?= $uri->getSegment(3); ?>;
			var promises = [];
			$("#alerts").html("");
			$("#myModalsave").modal("show");
			$("#myModalsave .modal-body button").prop("disabled", true);
			$("#myModalsave .modal-body button").text("Saving");
			$("#alerts").fadeIn("fast");
			$('#dg').datagrid('unselectAll');

			$.each(rows, function (i, row) {
				$('#dg').datagrid('endEdit', i);
				var url = '../../kpi_insert/' + prjct_id + '/' + cmpny_id + '/' + row.flow_id + '/' + row.flow_type_id + '/' + row.prcss_id + '/' + row.allocation_id;

				console.log(row.allocation_id);
				var csrfToken = $('meta[name="csrf_token"]').attr('content');

				var data = {
					myData: JSON.stringify(row),
					csrf_test_name: csrfToken
				};

				var request = $.ajax({
					url: url,
					type: 'POST',
					data: data,
					success: function (data, textStatus, xhr) {
						insertInline(i + 1, data);

						if (data.indexOf("red") >= 0) {
							$('#dg').datagrid('selectRow', i);
						}
					},
					error: function (xhr, textStatus, errorThrown) {
						console.log('AJAX Error:', textStatus, errorThrown);
						console.log('Response:', xhr.responseText);
					},
				});

				promises.push(request); // Store the promise in the array
			});

			// Allow doing something after all requests in the loop are finished
			$.when.apply(null, promises).done(function () {
				$("#myModalsave .modal-body button").prop("disabled", false);
				$("#myModalsave .modal-body button").text("Done");
				// deneme();
			});
		}
	}




	function reject() {
		$('#dg').datagrid('rejectChanges');
		editIndex = undefined;
	}
	function getChanges() {
		var rows = $('#dg').datagrid('getChanges');
		alert(rows.length + ' rows are changed!');
	}

	//allows to sort the answers/rows from the asynchronous post from the save (accept() function)
	function insertInline(rownumber, data) {
		var curDomElement;
		var prevDomElement;
		var insertBefore;
		$('#alerts div').each(function (index) {
			prevDomElement = curDomElement;
			curDomElement = $(this);
			if (parseInt(curDomElement.data('row')) > rownumber) {
				insertBefore = curDomElement;
				return false;
			}
		});
		if (insertBefore) {
			$("<div data-row=" + rownumber + ">Row " + rownumber + ": " + data + "</div>").insertBefore(insertBefore);
		} else {
			$("#alerts").append("<div data-row=" + rownumber + ">Row " + rownumber + ": " + data + "</div>");
		}
	}

</script>
<!-- <script type="text/javascript">
	function deneme() {
		var prjct_id = <?= $uri->getSegment(2); ?>;
		var cmpny_id = <?= $uri->getSegment(3); ?>;

		var prcss_array = new Array();
		var flow_array = new Array();
		var flow_type_array = new Array();
		var nameofref = new Array();
		var kpi = new Array();
		var kpi2 = new Array();
		var index = 0;
		$.ajax({
			type: "GET",
			dataType: 'json',
			url: '<?= base_url('kpi_calculation_chart'); ?>/' + prjct_id + '/' + cmpny_id,
			success: function (data) {
				if (data['allocation'].length != 0) {
					//console.log(data['allocation']);
					for (var i = 0; i < data['allocation'].length; i++) {
						if (data['allocation'][i].benchmark_kpi != 0) {
							prcss_array[index] = data['allocation'][i].prcss_name;
							flow_array[index] = data['allocation'][i].flow_name;
							flow_type_array[index] = data['allocation'][i].flow_type_name;
							nameofref[index] = data['allocation'][i].nameofref;

							kpi[index] = data['allocation'][i].kpi / data['allocation'][i].benchmark_kpi * 100;
							//console.log(kpi[index]);
							//kpi2[index] = 100-Math.abs(kpi[index]);
							kpi2[index] = 0;
							index++;
						}
					}

					//console.log(kpi2);
					var data = new google.visualization.DataTable();
					//console.log(data);
					var newData = new Array(index);
					for (var i = 0; i < index + 1; i++) {
						newData[i] = new Array(4);
					}

					newData[0][0] = 'Genre';
					newData[0][1] = '';
					newData[0][2] = 'Company performance relative to benchmark';
					newData[0][3] = { role: 'annotation' };
					newData[0][4] = { role: 'style' };

					for (var i = 1; i < index + 1; i++) {
						newData[i][0] = prcss_array[i - 1] + " (" + flow_array[i - 1] + "-" + flow_type_array[i - 1] + " / " + nameofref[i - 1] + ")";
						if (kpi[i - 1] < 0) {
							newData[i][1] = 0;
						}
						else {
							newData[i][1] = kpi2[i - 1];
						}

						newData[i][2] = Math.abs(Math.round(kpi[i - 1]));

						newData[i][3] = '';
						//console.log(kpi[i-1]);
						if (kpi[i - 1] < 100) {
							newData[i][4] = 'green';
						}
						else if (kpi[i - 1] == "100") {
							newData[i][4] = 'yellow';
						}
						else {
							newData[i][4] = 'red';
						}
					}

					var data2 = google.visualization.arrayToDataTable(newData);

					var options = {
						title: 'red: "Exceed Benchmark-KPI" \n yellow: "Equal to Benchmark-KPI" \n green: "Better than Benchmark-KPI"',
						titleTextStyle: { color: '#d0d0d0', bold: 'false' },
						legend: { position: "none", },
						height: 600,
						bar: { groupWidth: '75%' },
						isStacked: true,
						vAxis: { title: "[%] of Benchmark KPI", viewWindow: { max: 370 } },
						hAxis: { title: 'Process and KPI definition', titleTextStyle: { color: 'green' } },
					};
					var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
					chart.draw(data2, options);
				}
			}
		});
	};
</script> --> 
<!-- <script type="text/javascript">
	google.load("visualization", "1", { packages: ["corechart"] });
	google.setOnLoadCallback(deneme);
</script>