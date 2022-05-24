<!DOCTYPE html>
<html lang="en">

<head>
  <link rel="icon" href="<?= base_url('assets/images/favicon.png'); ?>" >
  <meta charset="utf-8">
  <title>CELERO</title>
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <!-- Loading Bootstrap -->
  <link href="<?= base_url('assets/bootstrap/css/bootstrap.css'); ?>" rel="stylesheet">

  <!-- Loading Flat UI -->
  <link href="<?= base_url('assets/css/flat-ui.css'); ?>" rel="stylesheet">
  <link href="<?= base_url('assets/css/custom.css'); ?>" rel="stylesheet">
  <link href="<?= base_url('assets/css/selectize.css'); ?>" rel="stylesheet">
  <link href="<?= base_url('assets/css/miller.css'); ?>" rel="stylesheet">
  <link rel="stylesheet" href="<?= base_url('assets/css/font-awesome.min.css'); ?>">
    <!--<link href="<?php // echo base_url('assets/css/jquery-ui-1.10.4.custom.css'); ?>" rel="stylesheet">

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements. All other JS at the end of file. -->
    <!--[if lt IE 9]>
      <script src="js/html5shiv.js"></script>

      <![endif]-->

      <script src="<?= base_url('assets/js/jquery-3.3.1.min.js'); ?>"></script>
      <script src="<?= base_url('assets/js/bootstrap.min.js'); ?>"></script>
      
      <!--[if lt IE 9]><script src="http://cdnjs.cloudflare.com/ajax/libs/es5-shim/2.0.8/es5-shim.min.js"></script><![endif]-->
      <?php 
       $uri = current_url(true);

      if($uri->getSegment(1)!="isscoping" and $uri->getSegment(1)!="isscopingauto"
        and $uri->getSegment(1)!="isScopingAutoPrjBase"
        and $uri->getSegment(1)!="isScopingAutoPrjBaseMDF"
        and $uri->getSegment(1)!="isScopingPrjBaseMDF"
        and $uri->getSegment(1)!="isScopingPrjBase"
        and $uri->getSegment(1)!="scenarios"
        and $uri->getSegment(1)!="cost_benefit"
        and $uri->getSegment(1)!="kpi_calculation"): ?>
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
      <script type="text/javascript" src="<?= base_url('assets/js/miller.js'); ?>"></script>
    <?php endif ?>
  </head>
  <body>

    <nav class="navbar navbar-default navbar-lg" style="margin-bottom:0px;">
      <a class="navbar-brand" href="<?= base_url(); ?>" style="color:white;">CELERO</a>
      <form class="navbar-form navbar-right" action="<?= base_url('search'); ?>" method="post" role="search" style="display: table;">
        <div class="form-group">
          <div class="input-group" style="display:block;">
            <input name="term" class="form-control" id="navbarInput-01" type="search" placeholder="<?= lang("Validation.search"); ?>">
            <button type="submit" class="btn"><span style="color:black;" class="fui-search"></span></button>
          </div>
        </div>
      </form>
      <!--TODO: SUBTITLE <a id="subtitle"> <?= lang('celerodescription'); ?></a> -->
      <ul class="nav navbar-nav navbar-left ust-nav">
        <li class="navtus" data-rel="about"><a id="l0" href="#"><i class="fa fa-info-circle"></i> <?= lang("Validation.about"); ?></a></li>
        <!-- <li class="navtus" data-rel="companies"><a id="l2" href="#" ><i class="fa fa-building-o"></i> <?= lang("Validation.companies"); ?></a></li>
        <li class="navtus" data-rel="projects"><a id="l3" href="#" ><i class="fa fa-globe"></i> <?= lang("Validation.projects"); ?></a></li> -->
        <li class="navtus" data-rel="analysis"><a id="l4" href="#" ><i class="fa fa-recycle"></i> <?= lang("Validation.services"); ?></a></li>        
        <li class="navtus" data-rel="cases"><a id="l3" href="#" ><i class="fa fa-book"></i> <?= lang("Validation.cases"); ?></a></li>
        <li class="navtus" data-rel="profiles"><a id="l1" href="#" ><i class="fa fa-group"></i> <?=  lang("Validation.account"); ?></a></li>
        <li data-rel="help"><a id="l6" href="<?= base_url('help'); ?>"><i class="fa fa-question-circle"></i>
          <?= lang("Validation.help"); ?></a></li>
      </ul>
    </nav>

    <div class="content-container" style="margin-bottom: 20px;display: block;height: 52px;">

      <ul id="about" class="nav navbar-nav alt-nav" style="display:none;">
        <li><a href="#" class="nav-info"></a></li>
        <li><a href="<?= base_url('functionalities'); ?>"><i class="fa fa-dashboard"></i> <?= lang("Validation.functionalities"); ?></a></li>
        <li><a href="<?= base_url('contactus'); ?>"><i class="fa fa-envelope"></i> <?= lang("Validation.whoarewe"); ?></a></li>
        <li><a href="<?= base_url('whatwedo'); ?>"><i class="fa fa-question-circle"></i> <?= lang("Validation.whatwedo"); ?></a></li>
        <li><a href="<?= base_url('legal'); ?>"><i class="fa fa-gavel"></i> <?= lang("Validation.legal"); ?></a></li>
      </ul>

      <ul id="manual" class="nav navbar-nav alt-nav" style="display:none;">
        <li><a href="#" class="nav-info"></a></li>
        <li><a href="<?= base_url('help'); ?>"><i class="fa fa-envelope"></i><?= lang("Validation.usermanual"); ?>, Video Instructions & FAQ</a></li>
      </ul>

      <ul id="cases" class="nav navbar-nav alt-nav" style="display:none;">
        <li><a href="#" class="nav-info"></a></li>
        <li class="head-li"><a href="<?= base_url('cases'); ?>"><i class="fa fa-book"></i> Case studies </a></li>
      </ul>

      <ul id="profiles" class="nav navbar-nav alt-nav" style="display:none;">
        <li><a href="#" class="nav-info"></a></li>
        <!-- TODO where to place Consultant list? under Help?
         <li><a href="<?= base_url('users'); ?>"><i class="fa fa-group"></i> <?= lang("Validation.consultants"); ?></a></li> -->
        <?php
        if(session()->username):
          $tmp = session()->username;
          
        ?>
            <li class="head-li"><a href="<?= base_url('user/'.$tmp); ?>" style="text-transform: capitalize; padding: 15px 1px 15px 21px"" ><i class="fa fa-user"></i> <?= $tmp; ?></a></li>
            <li class="head-li"><a href="<?= base_url('profile_update'); ?>" ><i class="fa fa-pencil-square-o"></i> <?= lang("Validation.updateprofile"); ?></a></li>
            <li class="head-li"><a href="<?= base_url('datasetexcel'); ?>"><i class="fa fa-globe"></i> Import UBP values</a></li>
            <li class="head-li"><a href="<?= base_url('mycompanies'); ?>" style="padding: 15px 1px 15px 21px"><i class="fa fa-building-o"></i> <?= lang("Validation.mycompanies"); ?></a></li>
            <?php if (session()->role_id == 1): ?>            
              <li class="head-li"><a href="<?= base_url('companies'); ?>"><i class="fa fa-building-o"></i> <?= lang("Validation.allcompanies"); ?></a></li>
            <?php endif ?>
            <li class="head-li"><a href="<?= base_url('myprojects'); ?>" style="padding: 15px 1px 15px 21px"; color:white;"><i class="fa fa-globe"></i> <?= lang("Validation.myprojects"); ?></a></li>
            <?php if (session()->role_id == 1): ?>            
              <li class="head-li"><a href="<?= base_url('projects'); ?>"><i class="fa fa-globe"></i> <?= lang("Validation.allprojects"); ?></a></li>

            <?php endif ?>
            <li class="head-li">
              <div class="dropdown">
                <button class="btn-link dropdown-toggle" type="button" id="dropdownMenu2" data-toggle="dropdown" aria-expanded="true" style="padding: 12px 20px; color:white;">
                <i class="fa fa-plus-circle"></i> <?= lang("Validation.add"); ?>
                </button>
                <ul class="dropdown-menu dropdown-red" role="menu" aria-labelledby="dropdownMenu2">
                  <li><a href="<?= base_url('newcompany'); ?>">- <?= lang("Validation.createcompany"); ?></a></li>
                  <li><a href="<?= base_url('newproject'); ?>">- <?= lang("Validation.createproject"); ?></a></li>
                </ul>
              </div>
            </li>
            <li class="pull-right"><a href="<?= base_url('logout'); ?>"><i class="fa fa-sign-out"></i> <?= lang("Validation.logout"); ?></a></li>
        <?php else: ?>
            <li class="head-li"><a href="<?= base_url('login'); ?>"><i class="fa fa-sign-in"></i> <?= lang("Validation.login"); ?></a></li>
            <li class="head-li"><a href="<?= base_url('register'); ?>"><i class="fa fa-plus"></i> <?= lang("Validation.register"); ?></a></li>
        <?php endif ?>
    </ul>

    <ul id="companies" class="nav navbar-nav alt-nav" style="display:none;">
      <li><a href="#" class="nav-info"></a></li>
      <?php if (isset(session()->username)): ?>
        <li><a href="<?= base_url('mycompanies'); ?>"><i class="fa fa-building-o"></i> <?= lang("Validation.mycompanies"); ?></a></li>
        <?php if(isset(session()->project_name)): ?>
          <li><a href="<?= base_url('projectcompanies'); ?>"><i class="fa fa-building-o"></i> <?= lang("Validation.projectcompanies"); ?></a></li>
        <?php endif ?>
      <?php endif ?>
      <li><a href="<?= base_url('companies'); ?>"><i class="fa fa-building-o"></i> <?= lang("Validation.allcompanies"); ?></a></li>
      <?php if (isset(session()->username)): ?>
        <li class="head-li"><a href="<?= base_url('newcompany'); ?>"><i class="fa fa-plus-square"></i> <?= lang("Validation.createcompany"); ?></a></li>
      <?php endif ?>
    </ul>

    <ul id="projects" class="nav navbar-nav alt-nav" style="display:none;">
         <li><a href="#" class="nav-info"></a></li>
      <?php if (isset(session()->username)): ?>
        <li><a href="<?= base_url('myprojects'); ?>"><i class="fa fa-globe"></i> <?= lang("Validation.myprojects"); ?></a></li>
      <?php endif ?>
      <li><a href="<?= base_url('projects'); ?>"><i class="fa fa-globe"></i> <?= lang("Validation.allprojects"); ?></a></li>
      <?php if (isset(session()->username)): ?>
        <li><a href="<?= base_url('newproject'); ?>"><i class="fa fa-plus-circle"></i> <?= lang("Validation.createproject"); ?></a></li>
      <?php endif ?>
      <?php if(isset(session()->project_id)): ?>
        <li class="pull-right"><a href="<?= base_url('closeproject'); ?>"><i class="fa fa-times-circle"></i> <?= lang("Validation.closeproject"); ?></a></li>
        <li class="pull-right"><a href="<?= base_url('project/'.session()->project_id); ?>"><?= session()->project_name['name'] ?></a></li>
      <?php endif ?>
    </ul>

    <ul id="analysis" class="nav navbar-nav alt-nav" style="display:none;">
         <li><a href="#" class="nav-info"></a></li>
      <?php if (isset(session()->username)): ?>
        <?php if(isset(session()->project_id)): ?>
          <li><a href="<?= base_url('cpscoping'); ?>"><i class="fa fa-recycle"></i> <?= lang("Validation.cpidentification"); ?></a></li>
          <li>
            <div class="dropdown">
              <button class="btn-link dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-expanded="true" style="padding: 12px 0px; color:white;">
                <i class="fa fa-exchange"></i> <?= lang("Validation.isidentification"); ?>
                <span class="caret"></span>
              </button>
              <ul class="dropdown-menu dropdown-inverse" role="menu" aria-labelledby="dropdownMenu1">
                <!--<li role="presentation"><a role="menuitem" tabindex="-1" href="<?= base_url('isScopingPrjBase'); ?>">Manual IS</a></li>
                <li role="presentation"><a role="menuitem" tabindex="-1" href="<?= base_url('isScopingAutoPrjBase'); ?>">Automated IS</a></li>-->
                <li role="presentation"><a role="menuitem" tabindex="-1" href="<?= base_url('isScopingPrjBaseMDF'); ?>">Manual IS</a></li>
                <li role="presentation"><a role="menuitem" tabindex="-1" href="<?= base_url('isScopingAutoPrjBaseMDF'); ?>">Automated IS</a></li>
                <li role="presentation"><a role="menuitem" tabindex="-1" href="<?= base_url('isscenarios'); ?>">IS Scenarios(Supervisors)</a></li>
                <li role="presentation"><a role="menuitem" tabindex="-1" href="<?= base_url('isscenariosCns'); ?>">IS Scenarios(Consultants)</a></li>
              </ul>
            </div>
          </li>
          <li><a href="<?= base_url('cost_benefit'); ?>"><i class="fa fa-euro"></i> <?= lang("Validation.costbenefitanalysis"); ?></a></li>
          <li><a href="<?= base_url('nis'); ?>"><i class="fa fa-exchange"></i> <?= lang("Validation.nis"); ?></a></li>
          <!--link to the ecotracking is ".not-active" atm
          <li><a class="not-active" title="Not available yet"><i class="fa fa-area-chart"></i> <?= lang("Validation.ecotracking"); ?></a></li>-->
          <!--link to the gis panel moved to the last position and is ".not-active" atm 
          <li><a class="not-active" title="Not available yet"><i class="fa fa-globe"></i> <?= lang("Validation.gis"); ?></a></li>--> 
          <li class="pull-right"><a href="<?= base_url('closeproject'); ?>" style="padding: 15px 10px;"><i class="fa fa-times-circle" title="Close Project"></i></a></li>   
          <li class="pull-right"><a href="<?= base_url('project/'.session()->project_id); ?>" style="padding: 15px 1px;">Project: <?= session()->project_name['name']; ?></a></li>
        <?php else: ?>
          <li><a href="<?= base_url('projects'); ?>"><?= lang("Validation.analysisinfo"); ?></a></li>
          <!--<ul class="list-inline" style="margin:0px;">
            <li class="head-li"><a href="<?= base_url('openproject'); ?>"><i class="fa fa-plus-square-o"></i> Open Project</a></li>
          </ul> -->
        <?php endif ?>
      <?php else: ?>
      <li><a href="#"><?= lang("Validation.analysisinfo2"); ?></a></li>
      <?php endif ?>
    </ul>

  </div>
  <div class="clearfix" style="margin-bottom: 10px;"></div>

  <script type="text/javascript">
      var project_durum = <?php if(isset(session()->project_id)){echo "true";}else{ echo "false";} ?>

      var logged_in = <?php if(isset(session()->username)){echo "true";}else{ echo "false";} ?>

        $( document ).ready(function() {
            var pathname = window.location.pathname;
            //console.log(pathname);
            if (pathname == "/" && logged_in){
                $('#l1').css('background-color', '#901F0F');
                $('.content-container ul.nav').hide();
                $('#profiles').fadeIn('slow');
            }
            else if ((pathname == "/") || (pathname.toLowerCase().indexOf("functionalities") >= 0) || (pathname.toLowerCase().indexOf("contactus") >= 0) || (pathname.toLowerCase().indexOf("whatwedo") >= 0) || (pathname.toLowerCase().indexOf("legal") >= 0)) {
                $('.content-container ul.nav').hide();
                $('#about').fadeIn('slow');
            }            
            else if (pathname.toLowerCase().indexOf("/project") >= 0 && pathname != "/projects"){
                $('#l4').css('background-color', '#84BFC3');
                $('.content-container ul.nav').hide();
                $('#analysis').fadeIn('slow');
            }

            else if ((pathname.toLowerCase().indexOf("cpscoping") >= 0) || (pathname.toLowerCase().indexOf("isscoping") >= 0) || (pathname.toLowerCase().indexOf("isscenarios") >= 0) || (pathname.toLowerCase().indexOf("cost_benefit") >= 0) || (pathname.toLowerCase().indexOf("nis") >= 0) || (pathname.toLowerCase().indexOf("kpi_calculation") >= 0) || (pathname.toLowerCase().indexOf("ecotracking") >= 0) ){
                $('#l4').css('background-color', '#84BFC3');
                $('.content-container ul.nav').hide();
                $('#analysis').fadeIn('slow');
            }

            else if ((pathname.toLowerCase().indexOf("cases") >= 0) ){
                $('#l3').css('background-color', '#15474A');
                $('.content-container ul.nav').hide();
                $('#cases').fadeIn('slow');
            }

            else if ((pathname.toLowerCase().indexOf("manual") >= 0) || (pathname.toLowerCase().indexOf("help") >= 0)){
                $('.content-container ul.nav').hide();
                $('#manual').fadeIn('slow');
            }
            else {
                $('#l1').css('background-color', '#901F0F');
                $('.content-container ul.nav').hide();
                $('#profiles').fadeIn('slow');
            }
        });

        $(".navtus").click(function(e) {
            e.preventDefault();
            if(!$('#' + $(this).data('rel')).is(":visible")){
                $('.content-container ul.nav').hide();
                $('#' + $(this).data('rel')).fadeIn('slow');
            }
            if($(this).data('rel') == "about"){
                $('#l0').css('background-color', '#2D8B42');
            }      
            if($(this).data('rel') == "profiles"){
                $('#l1').css('background-color', '#901F0F');
            }
            else if($(this).data('rel') == "companies"){
                $('#l2').css('background-color', '#901F0F');
            }
            else if($(this).data('rel') == "cases"){
                $('#l3').css('background-color', '#15474A');
            }
            else if($(this).data('rel') == "analysis"){
                $('#l4').css('background-color', '#84BFC3');
            }
            $(this).siblings().find("a").css( "background-color", "#2D8B42" );
        });
  </script>