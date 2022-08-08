<!--<!DOCTYPE html>-->
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>CELERO</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    
    
    <link id="bs-css" href="<?= base_url('assets/admin/css/bootstrap-spacelab.css'); ?>" rel="stylesheet" type="text/css">
	<style type="text/css">
	  body {
		padding-bottom: 40px;
	  }
	  .sidebar-nav {
		padding: 9px 0;
	  }
	</style>  
        <link href="<?= base_url('assets/admin/css/charisma-app.css'); ?>" rel="stylesheet" type="text/css">
        <!--<link href='bower_components/fullcalendar/dist/fullcalendar.css' rel='stylesheet'>
        <link href='bower_components/fullcalendar/dist/fullcalendar.print.css' rel='stylesheet' media='print'>
        <link href='bower_components/chosen/chosen.min.css' rel='stylesheet'>
        <link href='bower_components/colorbox/example3/colorbox.css' rel='stylesheet'>
        <link href='bower_components/responsive-tables/responsive-tables.css' rel='stylesheet'>
        <link href='bower_components/bootstrap-tour/build/css/bootstrap-tour.min.css' rel='stylesheet'>-->
        <link href='<?= base_url('assets/admin/css/jquery.noty.css'); ?>' rel='stylesheet' type="text/css">
        <link href='<?= base_url('assets/admin/css/noty_theme_default.css'); ?>' rel='stylesheet' type="text/css">
        <link href='<?= base_url('assets/admin/css/elfinder.min.css'); ?>' rel='stylesheet' type="text/css">
        <link href='<?= base_url('assets/admin/css/elfinder.theme.css'); ?>' rel='stylesheet' type="text/css">
        <link href='<?= base_url('assets/admin/css/jquery.iphone.toggle.css'); ?>' rel='stylesheet' type="text/css">
        <link href='<?= base_url('assets/admin/css/bootstrap-default.css'); ?>' rel='stylesheet' type="text/css">
        <link href='<?= base_url('assets/admin/css/uploadify.css'); ?>' rel='stylesheet' type="text/css">
        <link href="<?= base_url('assets/admin/css/bootstrap-default.css'); ?>" rel="stylesheet" type="text/css">
        <link href="<?= base_url('assets/is/themes/bootstrap/easyui.css'); ?>" rel="stylesheet" type="text/css">
        <link href='<?= base_url('assets/admin/css/bootstrap-default.css'); ?>' rel='stylesheet'>  
            
            
        <!-- Loading Flat UI -->
        <!--<link href="<?= base_url('assets/css/flat-ui.css'); ?>" rel="stylesheet">
        <link href="<?= base_url('assets/css/custom.css'); ?>" rel="stylesheet">
        <link href="<?= base_url('assets/css/selectize.css'); ?>" rel="stylesheet">
        <link rel="stylesheet" href="<?= base_url('assets/css/font-awesome.min.css'); ?>">-->
        
        <script src="<?= base_url('assets/admin/jquery-1.7.2.min.js'); ?>"></script>
        <!--<script src="<?php /*echo base_url('assets/js/jquery-ui-1.10.4.custom.js');*/ ?>"></script>-->
        <script src="<?= base_url('assets/admin/jquery-ui-1.8.21.custom.min.js'); ?>"></script>
        
        
        <!--<link href="<?php // echo base_url('assets/css/jquery-ui-1.10.4.custom.css'); ?>" rel="stylesheet">

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements. All other JS at the end of file. -->
    <!--[if lt IE 9]>
      <script src="js/html5shiv.js"></script>  
      <![endif]-->

      <!--<script src="<?= base_url('assets/js/jquery-1.10.2.min.js'); ?>"></script>
      <script src="<?= base_url('assets/admin/jquery-ui-1.8.21.custom.min.js'); ?>"></script>
      <script src="<?= base_url('assets/js/bootstrap.min.js'); ?>"></script>
      <script type="text/javascript" src="<?= base_url('assets/is/jquery.easyui.min.js'); ?>"></script>-->
      
      <!--[if lt IE 9]><script src="http://cdnjs.cloudflare.com/ajax/libs/es5-shim/2.0.8/es5-shim.min.js"></script><![endif]-->
      <?php if($this->uri->segment(1)!="isscoping" and $this->uri->segment(1)!="isscopingauto"
        and $this->uri->segment(1)!="isScopingAutoPrjBase"
        and $this->uri->segment(1)!="isScopingAutoPrjBaseMDF"
        and $this->uri->segment(1)!="isScopingPrjBaseMDF"
        and $this->uri->segment(1)!="isScopingPrjBase"
        and $this->uri->segment(1)!="scenarios"
        and $this->uri->segment(1)!="cost_benefit"
        and $this->uri->segment(1)!="kpi_calculation"): ?>
        <script src="<?= base_url('assets/js/selectize.min.js'); ?>"></script>
        <script type="text/javascript">
          $(function() {
            $('#selectize').selectize({
              create: true,
              sortField: 'text'
            });
          //$( "select" ).selectize();
        });
      </script>
    <?php endif ?>
        
   </head>

<body style="font-family: 'Helvetica Neue', Helvetica, arial, sans-serif;">

    