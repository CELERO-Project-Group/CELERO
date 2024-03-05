<!-- for datepicker -->
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>

<script>
	$(function () {
		$(document).tooltip();
	});
</script>

<div class="container">
	<?php
	if ($validation != NULL)
		echo $validation->listErrors();
	?>

	<?= form_open('newproject'); ?>
	<?= csrf_field() ?>
	<div class="row">
		<div class="col-md-8">

			<div class="form-group">
				<label for="projectName">
					<?= lang("Validation.name"); ?> <span class="small" style="color:red;">*Required</span>
				</label>
				<input type="text" class="form-control" id="projectName" placeholder="<?= lang("Validation.name"); ?>"
					value="<?= set_value('projectName'); ?>" name="projectName">
			</div>

			<div class="form-group">
				<label for="datepicker-01">
					<?= lang("Validation.startdate"); ?> <span class="small" style="color:gray;">Optional</span>
				</label>
				<div class="input-group">
					<span class="input-group-btn">
						<button id="datebtn" class="btn" type="button" style="height: 38px; border: 1px solid;"><span
								class="fui-calendar"></span></button>
					</span>
					<input type="text" class="form-control" value="<?= set_value('datepicker'); ?>" id="datepicker-01"
						name="datepicker">
				</div>
			</div>

			<div class="form-group">
				<label for="status">
					<?= lang("Validation.status"); ?>
				</label>
				<i class="fa fa-info-circle" title="Give your Projects a status to keep track of them."></i>
				<div>
					<select id="status" class="info select-block" name="status">
						<?php foreach ($project_status as $status): ?>
							<option value="<?= $status['id']; ?>">
								<?= $status['name']; ?>
							</option>
						<?php endforeach ?>
					</select>
				</div>
			</div>

			<div class="form-group">
				<label for="description">
					<?= lang("Validation.description"); ?> <span class="small" style="color:red;">*Required</span>
				</label>
				<textarea class="form-control" rows="3" name="description" id="description"
					placeholder="<?= lang("Validation.description"); ?>"><?= set_value('description'); ?></textarea>
			</div>

			<div class="form-group">
				<label for="assignCompany">
					<?= lang("Validation.assigncompany"); ?> <span class="small" style="color:red;">*Required</span>
				</label>
				<!--  <input type="text" id="companySearch" />	-->
				<i class="fa fa-info-circle" title="Choose the Companies you want to analyse in this Project."></i>

				<select multiple="multiple" title="Choose at least one" class="select-block" id="assignCompany"
					name="assignCompany[]">

					<?php foreach ($companies as $company): ?>
						<option value="<?= $company['id']; ?>">
							<?= $company['name']; ?>
						</option>
					<?php endforeach ?>
				</select>
			</div>
			<div class="form-group">
				<label for="assignConsultant">
					<?= lang("Validation.assignconsultant"); ?> <span class="small" style="color:red;">*Required</span>
				</label>
				<i class="fa fa-info-circle"
					title="Choose the corresponding consultants to the Project. They will have full access to this project."></i>

				<select multiple="multiple" title="Choose at least one" class="select-block" id="assignConsultant"
					name="assignConsultant[]">
					<?php foreach ($consultants as $consultant): ?>
						<option value="<?= $consultant['id']; ?>">
							<?= $consultant['name'] . ' ' . $consultant['surname'] . ' (' . $consultant['user_name'] . ')'; ?>
						</option>

					<?php endforeach ?>
				</select>
			</div>
			<div class="form-group">
				<label for="assignContactPerson">
					<?= lang("Validation.assigncontact"); ?> <span class="small" style="color:red;">*Required</span>
				</label>
				<select class="select-block" id="assignContactPerson" name="assignContactPerson">
					<option value="<?= session()->id ?>">Creator of the project (
						<?= session()->username ?>)
					</option>
				</select>
			</div>
			<button type="submit" class="btn btn-block btn-primary">
				<?= lang("Validation.createproject"); ?>
			</button>

		</div>
		<div class="col-md-4">

		</div>
	</div>
	</form>


</div>



<script type="text/javascript">
	// Datepicker on projects
	// jQuery UI Datepicker JS init
	var datepickerSelector = '#datepicker-01';
	//   $(datepickerSelector).datepicker({
	//     showOtherMonths: true,
	//     selectOtherMonths: true,
	//     dateFormat: "yy-mm-dd",
	//     yearRange: '-1:+1'
	//   }).prev('#datebtn').on('click', function (e) {
	//     e && e.preventDefault();
	//     $(datepickerSelector).focus();
	//   });
	// Initialize datepicker
	$(datepickerSelector).datepicker({
		showOtherMonths: true,
		selectOtherMonths: true,
		dateFormat: "yy-mm-dd",
		yearRange: '-1:+1'
	});

	// Attach click event listener with debugging statement
	$('#datebtn').on('click', function (e) {
		console.log('Button clicked!'); // Check if function is called on click
		e.preventDefault();
		$(datepickerSelector).focus(); // Focus on datepicker
	});

	// Now let's align datepicker with the prepend button
	$(datepickerSelector).datepicker('widget').css({ 'margin-left': -$(datepickerSelector).prev('#datebtn').outerWidth() });
</script>

<script type="text/javascript">
	$(document).ready(function () {
		$('#assignCompany').change(function () {
			var company = $(this).val();
			$.ajax({
				url: "<?= base_url('contactperson'); ?>",
				async: false,
				type: "POST",
				data: "company_id=" + company,
				dataType: "json",
				success: function (data) {
					//$('#assignContactPerson option').remove();

					for (var k = 0; k < data.length; k++) {
						for (var i = 0; i < data[k].length; i++) {
							var opt = data[k][i]['id'];
							if ($("#assignContactPerson option[value='" + opt + "']").length == 0) {
								$("#assignContactPerson").append(new Option(data[k][i]['name'] + ' ' + data[k][i]['surname'] + ' - ' + data[k][i]['cmpny_name'], data[k][i]['id']));
							}
						}
					}
				}
			})
		});
	});
</script>