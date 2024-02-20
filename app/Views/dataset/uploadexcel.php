<div class="container">
    <h4>Add new excel</h4>
    <div style="border: 1px solid #d0d0d0; padding: 15px; margin-bottom: 20px; overflow:hidden;">
        <i>This will replace your whole excel data. Inserted data won't be affected. Only xls and xlsx filetype is allowed.</i>
        <div>For CELERO to correctly understand the input, the Excel has to be in the same Form as the Template.</div>

        <div style="padding: 20px 0; padding-bottom: 0px;">
            <!-- <?php
                // if(isset($error)) {
                //     echo "<div style=' color:#E74C3C;margin: 10px 0;padding: 15px;padding-bottom: 0;border: 1px solid;'>ERROR:</br>".$error."</div>";
                // }
                // else if (!isset($_FILES['excel_file']) || !$_FILES['excel_file']['error'] === UPLOAD_ERR_OK) {
                //     echo "<div style='margin: 10px 0;padding: 15px;padding-bottom: 20;border: 1px solid;'>No File uploaded yet.</div>";
                //   }
                // else {
                //     echo "<div style=' color:#2eb3e7;margin: 10px 0;padding: 15px;padding-bottom: 20;border: 1px solid;'>DONE:</br>You have successfully uploaded new file.</div>";
                // }
            ?> -->
            <?php if (session()->has('message')){ ?>
				<div class="alert <?=session()->getFlashdata('alert-class') ?>">
					<?=session()->getFlashdata('message') ?>
				</div>
			<?php } ?>
            <?= form_open_multipart('uploadExcel', "style='margin-top: 10px;float: left;'");?>
            <?= csrf_field() ?>
            <input type="file" name="excelFile" id="excelFile">
        </div>
        <input type="submit" value="Upload Data" style="float:right;" class="btn btn-info" />
        </form>
    </div>
    <a href="<?= site_url('datasetexcel') ?>" class="btn btn-default"><span class="glyphicon glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
        Return to Excel values management page</a>

</div>