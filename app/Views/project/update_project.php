<div class="container">
	<p class="lead"><?= lang("Validation.editprojectinfo"); ?></p>
	<script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>
	<?= form_open('update_project/'.$projects['id']); ?>
	<?= csrf_field() ?>
		<input class="form-control" id="id" value="<?= set_value('id',$projects['id']); ?>" name="id" type="hidden" />

		<div class="row">
			<div class="col-md-8">
				<div class="form-group">
	    			<label for="projectName"><?= lang("Validation.name"); ?></label>
	    			<input type="text" class="form-control" id="projectName" placeholder="<?= lang("Validation.name"); ?>" value="<?= set_value('projectName',$projects['name']); ?>" name="projectName">
	 			</div>
	 			<div class="form-group">
	 				<label for="datepicker-01"><?= lang("Validation.startdate"); ?></label>
	    			<div class="input-group">
				    	<span class="input-group-btn">
				      		<button id="datebtn" class="btn" type="button" style="height: 38px; border: 1px solid;"><span class="fui-calendar"></span></button>
				    	</span>
				    	<input type="text" class="form-control" value="<?= set_value('datepicker',$projects['start_date']); ?>" id="datepicker-01" name="datepicker" />
				  	</div>
	 			</div>
	 			<!-- <div class="form-group">
	    			<label for="status"><?php // lang("Validation.status"); ?></label>
	    			<div>
		    			<select id="status" class="info select-block" name="status">
		  					<?php // foreach ($project_status as $status): ?>
								<option value="<?php // $status['id']; ?>" <?php //if($status['id']==$projects['status_id'])  echo 'selected';  ?> > <?php // $status['name']; ?></option>
							<?php // endforeach ?>
						</select>
					</div>
	 			</div> -->
	 			<div class="form-group">
	    			<label for="description"><?= lang("Validation.description"); ?></label>
	    			<textarea class="form-control" rows="3" name="description" id="description" placeholder="Description" value=""><?= set_value('description',$projects['description']); ?></textarea>
	 			</div>
	 			<div class="form-group">
	    			<label for="assignCompany"><?= lang("Validation.assigncompany"); ?></label>
	    			<!--  <input type="text" id="companySearch" />	-->

	    			<select multiple="multiple"  class="select-block" id="assignCompany" name="assignCompany[]">

						<?php foreach ($companies as $company): ?>
							<option value="<?= $company['id']; ?>" <?php if(in_array($company['id'], $companyIDs)) echo 'selected';?> ><?= $company['name']; ?></option>
						<?php endforeach ?>
					</select>
	 			</div>
	 			<div class="form-group">
	    			<label for="assignConsultant"><?= lang("Validation.assignconsultant"); ?></label>
	    			<select multiple="multiple" class="select-block" id="assignConsultant" name="assignConsultant[]">

						<?php foreach ($consultants as $consultant): ?>
							<option value="<?= $consultant['id']; ?>" <?php if(in_array($consultant['id'], $consultantIDs)) echo 'selected';?>><?= $consultant['name'].' '.$consultant['surname'].' ('.$consultant['user_name'].')'; ?></option>
						<?php endforeach ?>
					</select>
	 			</div>
	 			<div class="form-group">
	    			<label for="assignContactPerson"><?= lang("Validation.assigncontact"); ?></label>
	    			<select  class="select-block" id="assignContactPerson" name="assignContactPerson">
	    			<?php foreach ($contactusers as $contacts): ?>
	    			<?php foreach ($contacts as $contactuser): ?>
							<option value="<?= $contactuser['id']; ?>"<?php if(in_array($contactuser['id'], $contactIDs)) echo 'selected';?>  ><?= $contactuser['name'].' '.$contactuser['surname'].' ('.$contactuser['cmpny_name'].')'; ?></option>
						<?php endforeach ?>
							<?php endforeach ?>
					</select>
					<!-- <?php print_r($contacts);?> -->
	 			</div>
	 			<br>
				<button type="submit" class="btn btn-inverse col-md-9"><?= lang("Validation.save"); ?></button>
    			<a href="<?= base_url('project/'.$projects['id']); ?>" class="btn btn-warning col-md-2 col-md-offset-1"><?= lang("Validation.cancel"); ?></a>
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
        url: "<?= base_url('contactperson');?>",
        async: false,
        type: "POST",
        data: "company_id="+company,
        dataType: "json",
        success: function(data) {
          //$('#assignContactPerson option').remove();

          for (var k = 0; k < data.length; k++) {
            for (var i = 0; i < data[k].length; i++) {
              var opt =data[k][i]['id'];
              if($("#assignContactPerson option[value='"+ opt +"']").length == 0)
              {
                $("#assignContactPerson").append(new Option(data[k][i]['name']+' '+data[k][i]['surname']+' - '+data[k][i]['cmpny_name'],data[k][i]['id']));
              }
            }
          }
        }
      })
    });
  });
</script>