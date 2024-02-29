<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>CELERO Admin Pages</title>
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
        <link href="/assets/admin/css/charisma-app.css" rel="stylesheet">
        <!--<link href='bower_components/fullcalendar/dist/fullcalendar.css' rel='stylesheet'>
        <link href='bower_components/fullcalendar/dist/fullcalendar.print.css' rel='stylesheet' media='print'>
        <link href='bower_components/chosen/chosen.min.css' rel='stylesheet'>
        <link href='bower_components/colorbox/example3/colorbox.css' rel='stylesheet'>
        <link href='bower_components/responsive-tables/responsive-tables.css' rel='stylesheet'>
        <link href='bower_components/bootstrap-tour/build/css/bootstrap-tour.min.css' rel='stylesheet'>-->
        <link href="/assets/admin/css/jquery.noty.css" rel="stylesheet">
        <link href="/assets/admin/css/noty_theme_default.css" rel="stylesheet">
        <link href="/assets/admin/css/elfinder.min.css" rel="stylesheet">
        <link href="/assets/admin/css/elfinder.theme.css" rel="stylesheet">
        <link href="/assets/admin/css/jquery.iphone.toggle.css" rel="stylesheet">
        <link href="/assets/admin/css/uploadify.css" rel="stylesheet">

        <script src="/assets/js/jquery-3.3.1.min.js"></script>
        <script src="https://unpkg.com/gijgo@1.9.14/js/gijgo.min.js" type="text/javascript"></script>
        <link href="https://unpkg.com/gijgo@1.9.14/css/gijgo.min.css" rel="stylesheet" type="text/css" />

        <script src="/assets/js/easy-ui-1.4.2.js"></script>
        <script src="/assets/js/bootstrap.min.js"></script>
        
        <script src="<?= base_url('assets/admin/jquery-1.7.2.min.js'); ?>"></script>
        <!--<script src="<?php /*echo base_url('assets/js/jquery-ui-1.10.4.custom.js');*/ ?>"></script>-->
        <script src="<?= base_url('assets/admin/jquery-ui-1.8.21.custom.min.js'); ?>"></script>
   </head>

<body>     
   <!-- topbar starts -->
	<div class="navbar">
		<div class="navbar-inner">
			<div class="container-fluid">
				<a class="btn btn-navbar" data-toggle="collapse" data-target=".top-nav.nav-collapse,.sidebar-nav.nav-collapse">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</a>
				<a class="brand" href=""> <img style="height: 60px;width: 164px;" alt="CELERO logo" src="../assets/images/anasayfa.png" /> <span>CELERO</span></a>
				
				<!-- theme selector starts -->
				<div class="btn-group pull-right theme-container" >
					<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
						<i class="icon-tint"></i><span class="hidden-phone"><?= lang("Validation.changeskin"); ?> </span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu" id="themes"> 
						<li><a data-value="classic" href="#"><i class="icon-blank"></i>Classic</a></li>
						<li><a data-value="cerulean" href="#"><i class="icon-blank"></i>Cerulean</a></li>
						<li><a data-value="cyborg" href="#"><i class="icon-blank"></i>Cyborg</a></li>
					 	<li><a data-value="redy" href="#"><i class="icon-blank"></i>Redy</a></li>
						<li><a data-value="journal" href="#"><i class="icon-blank"></i>Journal</a></li>
						<li><a data-value="simplex" href="#"><i class="icon-blank"></i>Simplex</a></li>
						<li><a data-value="slate" href="#"><i class="icon-blank"></i>Slate</a></li>
						<li><a data-value="spacelab" href="#"><i class="icon-blank"></i>Spacelab</a></li>
						<li><a data-value="united" href="#"><i class="icon-blank"></i>United</a></li>
					</ul>
				</div>
				<!-- theme selector ends -->
				
				<!-- user dropdown starts -->
				<div class="btn-group pull-right" >
					<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
						<i class="icon-user"></i><span class="hidden-phone"> <?= $userName;  ?></span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="<?= base_url("user/fhnwuser") ?>"><?= lang("Validation.myprofile"); ?></a></li>
						<li class="divider"></li>
						<li><a href="../logout"><?= lang("Validation.logout"); ?></a></li>
					</ul>
				</div>
				<!-- user dropdown ends -->
				
				<div class="top-nav nav-collapse">
					<ul class="nav">
						<li><a href="../../"><?= lang("Validation.mainpage"); ?></a></li>
						<li>
							<!--<form class="navbar-search pull-left">-->
								<input placeholder="<?= lang("Validation.search"); ?>" class="search-query span2" name="query" type="text">
							<!--</form>-->
						</li>
					</ul>
				</div><!--/.nav-collapse -->
			</div>
		</div>
	</div>