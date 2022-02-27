<?php

namespace Config;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

// Load the system's routing file first, so that the app and ENVIRONMENT
// can override as needed.
if (file_exists(SYSTEMPATH . 'Config/Routes.php')) {
    require SYSTEMPATH . 'Config/Routes.php';
}

/*
 * --------------------------------------------------------------------
 * Router Setup
 * --------------------------------------------------------------------
 */
$routes->setDefaultNamespace('App\Controllers');
$routes->setDefaultController('Home');
$routes->setDefaultMethod('index');
$routes->setTranslateURIDashes(false);
$routes->set404Override();
$routes->setAutoRoute(true);

/*
 * --------------------------------------------------------------------
 * Route Definitions
 * --------------------------------------------------------------------
 */

// We get a performance increase by specifying the default
// route since we don't have to scan directories.
// Language 
//disabled it
//$route->add('language/switch/(:any)'), 'langswitch/switchLanguage/$1';

// ADMIN
$route->add('admin/newFlow'), 'Admin::newFlow';
$route->add('admin/newProcess'), 'Admin::newProcess';
$route->add('admin/newEquipment'), 'Admin::newEquipment';
$route->add('admin/reports'), 'Admin::reports';
 
//Report
$route->add('report/(:any)')Rshow_single/$1';
$route->add('allreports')Rshow_all';
$route->add('admin/report'), 'Admin::report';

$route->add('admin/rpEmployeesList'), 'Admin::rpEmployeesList';
$route->add('admin/rpCompaniesList'), 'Admin::rpCompaniesList';
$route->add('admin/rpCompaniesInfoList'), 'Admin::rpCompaniesInfoList';
$route->add('admin/rpCompaniesProjectsList'), 'Admin::rpCompaniesProjectsList';
$route->add('admin/rpCompaniesProjectDetailsList'), 'Admin::rpCompaniesProjectDetailsList';
$route->add('admin/rpCompaniesNotInClustersList'), 'Admin::rpCompaniesNotInClustersList';
$route->add('admin/rpCompaniesWasteEmissionList'), 'Admin::rpCompaniesWasteEmissionList';
$route->add('admin/rpCompaniesProductionList'), 'Admin::rpCompaniesProductionList';
$route->add('admin/rpCompaniesProcessesList'), 'Admin::rpCompaniesProcessesList';
$route->add('admin/rpConsultantsList'), 'Admin::rpConsultantsList';
$route->add('admin/rpCompaniesInClustersList'), 'Admin::rpCompaniesInClustersList';
$route->add('admin/rpEquipmentList'), 'Admin::rpEquipmentList';
$route->add('admin/reportTest'), 'Admin::reportTest';
$route->add('admin/reportTest'), 'Admin::reportTest';
$route->add('admin/clusters'), 'Admin::clusters';
$route->add('admin/industrialZones'), 'Admin::industrialZones';
$route->add('admin/consultants'), 'Admin::consultants';
$route->add('admin/employees'), 'Admin::employees';
$route->add('admin/zoneEmployees'), 'Admin::zoneEmployees';
$route->add('admin/zoneCompanies'), 'Admin::zoneCompanies';
$route->add('createreport'), 'Reporting::create'; 

//IS scoping
$route->add('isscoping'), 'Isscoping::index';
$route->add('isscopingauto'), 'Isscoping::auto';
$route->add('isScopingAutoPrjBase'), 'Isscoping::autoprjbase';
$route->add('isScopingAutoPrjBaseMDF'), 'Isscoping::autoprjbaseMDF';
$route->add('isScopingAutoPrjBaseMDFTest'), 'Isscoping::autoprjbaseMDFTest';
$route->add('isScopingPrjBase'), 'Isscoping::prjbase';
$route->add('isScopingPrjBaseMDF'), 'Isscoping::prjbaseMDF';
$route->add('isscopingtooltip'), 'Isscoping::tooltip';
$route->add('isscopingtooltipscenarios'), 'Isscoping::tooltipscenarios';
$route->add('isscenarios'), 'Isscoping::isscenarios';
$route->add('isscenariosCns'), 'Isscoping::isscenariosCns';

//map
$route->add('map'), 'Map::index';
$route->add('mapHeader'), 'Map::mapHeader';


//Ecotracking
$route->add('ecotracking/(:any)/(:any)/(:any)/(:any)/(:any)'), 'Ecotracking::save/$1/$2/$3/$4/$5';
$route->add('ecotracking/json/(:any)/(:any)'), 'Ecotracking::json/$1/$2';
$route->add('ecotracking/(:any)/(:any)'), 'Ecotracking::show/$1/$2';
$route->add('ecotracking'), 'Ecotracking::index';

//Cost Benefit
$route->add('cost_benefit/(:any)/(:any)'), 'Cost_benefit::new_cost_benefit/$1/$2';
$route->add('cost_benefit'), 'Cost_benefit::index';
$route->add('cba/save/(:any)/(:any)/(:any)/(:any)'), 'Cost_benefit::save/$1/$2/$3/$4';

//Html Parse
$route->add('euro_dolar'), 'Cpscoping::dolar_euro_parse';

//Easy UI Denemeleri
$route->add('cp_allocation/deneme'), 'Cpscoping::deneme';
$route->add('cp_allocation/deneme_json'), 'Cpscoping::deneme_json';

//KPI
$route->add('kpi_json/(:any)/(:any)'), 'Cpscoping::kpi_json/$1/$2';
$route->add('kpi_calculation_chart/(:any)/(:any)'), 'Cpscoping::kpi_calculation_chart/$1/$2';
$route->add('kpi_insert/(:any)/(:any)/(:any)/(:any)/(:any)/(:any)'), 'Cpscoping::kpi_insert/$1/$2/$3/$4/$5/$6';
$route->add('kpi_calculation/(:any)/(:any)'), 'Cpscoping::kpi_calculation/$1/$2';
$route->add('search_result/(:any)/(:any)'), 'Cpscoping::search_result/$1/$2';

//CP
$route->add('Cpscoping/full_get/(:any)/(:any)/(:any)/(:any)'), 'Cpscoping::get_only_given_full/$1/$2/$3/$4';
$route->add('Cpscoping/deneme'), 'Cpscoping::deneme';
$route->add('Cpscoping/comment_save/(:any)/(:any)'), 'Cpscoping::comment_save/$1/$2';
$route->add('Cpscoping/allocated_table/(:any)/(:any)/(:any)/(:any)/(:any)'), 'Cpscoping::get_already_allocated_allocation_except_given/$1/$2/$3/$4/$5';
$route->add('Cpscoping/edit_allocation/(:any)'), 'Cpscoping::edit_allocation/$1';
$route->add('Cpscoping/file_upload/(:any)/(:any)'), 'Cpscoping::cp_scoping_file_upload/$1/$2';
$route->add('Cpscoping/file_delete/(:any)/(:any)'), 'Cpscoping::file_delete/$1/$2';
$route->add('Cpscoping/is_candidate_insert/(:any)/(:any)'), 'Cpscoping::cp_is_candidate_insert/$1/$2';
$route->add('Cpscoping/is_candidate_control/(:any)'), 'Cpscoping::cp_is_candidate_control/$1';
$route->add('Cpscoping/cost_ep/(:any)/(:any)/(:any)'), 'Cpscoping::cost_ep_value/$1/$2/$3';
$route->add('Cpscoping/get_allo/(:any)/(:any)/(:any)/(:any)/(:any)'), 'Cpscoping::get_allo_from_fname_pname/$1/$2/$3/$4/$5';
$route->add('Cpscoping/(:any)/(:any)/show'), 'Cpscoping::cp_show_allocation/$1/$2';
$route->add('Cpscoping/delete/(:any)/(:any)/(:any)'), 'Cpscoping::delete_allocation/$1/$2/$3';
$route->add('cp_allocation_array/(:any)'), 'Cpscoping::cp_allocation_array/$1';
$route->add('Cpscoping/(:any)/(:any)/allocation'), 'Cpscoping::cp_allocation/$1/$2';
$route->add('Cpscoping/pro/(:any)'), 'Cpscoping::p_companies/$1';
$route->add('Cpscoping'), 'Cpscoping::index';

//Password routes
$route->add('send_email_for_change_pass'), 'Password::send_email_for_change_pass';
$route->add('change_pass/(:any)'), 'Password::change_pass/$1';
$route->add('new_password_email'), 'Password::new_password_email';
$route->add('new_password/(:any)'), 'Password::new_password/$1';

$route->add('cluster'), 'Cluster::cluster_to_match_company';

$route->add('become_consultant'), 'User::become_consultant';
$route->add('profile_update'), 'User::user_profile_update';
$route->add('user/(:any)'), 'User::user_profile/$1';
$route->add('users'), 'User::show_all_users';
$route->add('register'), 'User::user_register';
$route->add('login'), 'User::user_login';
$route->add('logout'), 'User::user_logout';

//OPen project
$route->add('closeproject'), 'Project::close_project';
$route->add('openproject'), 'Project::open_project';
$route->add('update_project/(:any)'), 'Project::update_project/$1';
$route->add('newproject'), 'Project::new_project';
$route->add('projects'), 'Project::show_all_project';
$route->add('myprojects'), 'Project::show_my_project';
$route->add('contactperson'), 'Project::contact_person';
$route->add('project/(:any)'), 'Project::view_project/$1';
$route->add('deleteproject/(:any)'), 'Project::delete_project/$1';
$route->add('addConsultantToProject/(:any)'), 'Project::addConsultantToProject/$1';

$route->add('tuna_json/(:any)'), 'Company::get_company_info/$1';
$route->add('companySearch'), 'Company::company_search';
$route->add('update_company/(:any)'), 'Company::update_company/$1';
$route->add('newcompany'), 'Company::new_company';
$route->add('deletecompany/(:any)'), 'Company::delete_company/$1';
$route->add('companies'), 'Company::show_all_companies';
$route->add('nis/(:any)'), 'Company::isSelectionWithFlow/$1';
$route->add('nis'), 'Company::isSelectionWithFlow';
$route->add('mycompanies'), 'Company::show_my_companies';
$route->add('projectcompanies'), 'Company::show_project_companies';
$route->add('company/(:any)'), 'Company::companies/$1';
$route->add('addUsertoCompany/(:any)'), 'Company::addUsertoCompany/$1';
$route->add('removeUserfromCompany/(:any)/(:any)'), 'Company::removeUserfromCompany/$1/$2';

$route->add('search'), 'Search::search_pro';
$route->add('search/(:any)'), 'Search::search_pro/$1';

// Dataset
$route->add('deleteuserep/(:any)/(:any)'), 'User::deleteUserEp/$1/$2';
$route->add('datasetexcel'), 'User::dataFromExcel';
$route->add('uploadExcel'), 'User::uploadExcel';
$route->add('flow_and_component'), 'Dataset::flow_and_component';
$route->add('allocationlist/(:any)/(:any)'), 'Cpscoping::allocationlist/$1/$2';
$route->add('new_flow/(:any)'), 'Dataset::new_flow/$1';
$route->add('edit_flow/(:any)/(:any)/(:any)'), 'Dataset::edit_flow/$1/$2/$3';
$route->add('edit_component/(:any)/(:any)'), 'Dataset::edit_component/$1/$2';
$route->add('new_component/(:any)'), 'Dataset::new_component/$1';
$route->add('delete_flow/(:any)/(:any)'), 'Dataset::delete_flow/$1/$2';
$route->add('delete_component/(:any)/(:any)'), 'Dataset::delete_component/$1/$2';
$route->add('UBP_values'), 'Dataset::UBP_values';

$route->add('new_product/(:any)'), 'Dataset::new_product/$1';
$route->add('edit_product/(:any)/(:any)'), 'Dataset::edit_product/$1/$2';
$route->add('product'), 'Dataset::product';
$route->add('delete_product/(:any)/(:any)'), 'Dataset::delete_product/$1/$2';

$route->add('edit_process/(:any)/(:any)'), 'Dataset::edit_process/$1/$2';
$route->add('new_process/(:any)'), 'Dataset::new_process/$1';
$route->add('delete_process/(:any)/(:any)/(:any)'), 'Dataset::delete_process/$1/$2/$3';
$route->add('get_sub_process'), 'Dataset::get_sub_process';
$route->add('my_ep_values/(:any)/(:any)'), 'Dataset::my_ep_values/$1/$2';
$route->add('new_equipment/(:any)'), 'Dataset::new_equipment/$1';
$route->add('get_equipment_type'), 'Dataset::get_equipment_type';
$route->add('get_equipment_attribute'), 'Dataset::get_equipment_attribute';
$route->add('delete_equipment/(:any)/(:any)'), 'Dataset::delete_equipment/$1/$2';

$route->add('/'), 'Homepage::index';
$route->add('(:any)'] = 'Pages::view/$1';
$route->add('404_override'] = '';
/*
 * --------------------------------------------------------------------
 * Additional Routing
 * --------------------------------------------------------------------
 *
 * There will often be times that you need additional routing and you
 * need it to be able to override any defaults in this file. Environment
 * based routes is one such time. require() additional route files here
 * to make that happen.
 *
 * You will have access to the $routes object within that file without
 * needing to reload it.
 */
if (file_exists(APPPATH . 'Config/' . ENVIRONMENT . '/Routes.php')) {
    require APPPATH . 'Config/' . ENVIRONMENT . '/Routes.php';
}

