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
//$routes->add('language/switch/(:any)', 'langswitch/switchLanguage/$1');


// ADMIN
$routes->add('admin/newFlow', 'Admin::newFlow');
$routes->add('admin/newProcess', 'Admin::newProcess');
$routes->add('admin/newEquipment', 'Admin::newEquipment');
$routes->add('admin/reports', 'Admin::reports');
 
//Report
#$routes->add('report/(:any)', 'show_single/$1');
#$routes->add('allreports', 'show_all');
$routes->add('admin/report', 'Admin::report');

$routes->add('admin/rpEmployeesList', 'Admin::rpEmployeesList');
$routes->add('admin/rpCompaniesList', 'Admin::rpCompaniesList');
$routes->add('admin/rpCompaniesInfoList', 'Admin::rpCompaniesInfoList');
$routes->add('admin/rpCompaniesProjectsList', 'Admin::rpCompaniesProjectsList');
$routes->add('admin/rpCompaniesProjectDetailsList', 'Admin::rpCompaniesProjectDetailsList');
$routes->add('admin/rpCompaniesNotInClustersList', 'Admin::rpCompaniesNotInClustersList');
$routes->add('admin/rpCompaniesWasteEmissionList', 'Admin::rpCompaniesWasteEmissionList');
$routes->add('admin/rpCompaniesProductionList', 'Admin::rpCompaniesProductionList');
$routes->add('admin/rpCompaniesProcessesList', 'Admin::rpCompaniesProcessesList');
$routes->add('admin/rpConsultantsList', 'Admin::rpConsultantsList');
$routes->add('admin/rpCompaniesInClustersList', 'Admin::rpCompaniesInClustersList');
$routes->add('admin/rpEquipmentList', 'Admin::rpEquipmentList');
$routes->add('admin/reportTest', 'Admin::reportTest');
$routes->add('admin/reportTest', 'Admin::reportTest');
$routes->add('admin/clusters', 'Admin::clusters');
$routes->add('admin/industrialZones', 'Admin::industrialZones');
$routes->add('admin/consultants', 'Admin::consultants');
$routes->add('admin/employees', 'Admin::employees');
$routes->add('admin/zoneEmployees', 'Admin::zoneEmployees');
$routes->add('admin/zoneCompanies', 'Admin::zoneCompanies');
$routes->add('createreport', 'Reporting::create'); 

//IS scoping
$routes->add('isscoping/(:any)', 'Company::isSelectionWithFlow/$1');
$routes->add('isscoping', 'Company::isSelectionWithFlow');

//map
$routes->add('map', 'Map::index');
$routes->add('mapHeader', 'Map::mapHeader');


//Ecotracking
$routes->add('ecotracking/(:any)/(:any)/(:any)/(:any)/(:any)', 'Ecotracking::save/$1/$2/$3/$4/$5');
$routes->add('ecotracking/json/(:any)/(:any)', 'Ecotracking::json/$1/$2');
$routes->add('ecotracking/(:any)/(:any)', 'Ecotracking::show/$1/$2');
$routes->add('ecotracking', 'Ecotracking::index');

//Cost Benefit
$routes->add('cost_benefit/(:any)/(:any)', 'Cost_benefit::new_cost_benefit/$1/$2');
$routes->add('cost_benefit', 'Cost_benefit::index');
$routes->add('savenewisscoping', 'Cost_benefit::saveNewISScopingPotential');
$routes->add('cba/save/(:any)/(:any)/(:any)/(:any)', 'Cost_benefit::save/$1/$2/$3/$4');

//Html Parse
$routes->add('euro_dolar', 'Cpscoping::dolar_euro_parse');

//Easy UI Denemeleri
$routes->add('cp_allocation/deneme', 'Cpscoping::deneme');
$routes->add('cp_allocation/deneme_json', 'Cpscoping::deneme_json');

//KPI
$routes->add('kpi_json/(:any)/(:any)', 'Cpscoping::kpi_json/$1/$2');
$routes->add('kpi_calculation_chart/(:any)/(:any)', 'Cpscoping::kpi_calculation_chart/$1/$2');
$routes->add('kpi_insert/(:any)/(:any)/(:any)/(:any)/(:any)/(:any)', 'Cpscoping::kpi_insert/$1/$2/$3/$4/$5/$6');
$routes->add('kpi_calculation/(:any)/(:any)', 'Cpscoping::kpi_calculation/$1/$2');
$routes->add('search_result/(:any)/(:any)', 'Cpscoping::search_result/$1/$2');

//CP
$routes->add('cpscoping', 'Cpscoping::index');
$routes->add('cpscoping/full_get/(:any)/(:any)/(:any)/(:any)', 'Cpscoping::get_only_given_full/$1/$2/$3/$4');
// $routes->add('cpscoping/deneme', 'Cpscoping::deneme');
// $routes->add('cpscoping/comment_save/(:any)/(:any)', 'Cpscoping::comment_save/$1/$2');
$routes->add('cpscoping/allocated_table/(:any)/(:any)/(:any)/(:any)/(:any)', 'Cpscoping::get_already_allocated_allocation_except_given/$1/$2/$3/$4/$5');
$routes->add('cpscoping/edit_allocation/(:any)', 'Cpscoping::edit_allocation/$1');
// $routes->add('cpscoping/file_upload/(:any)/(:any)', 'Cpscoping::cp_scoping_file_upload/$1/$2');
// $routes->add('cpscoping/file_delete/(:any)/(:any)', 'Cpscoping::file_delete/$1/$2');
// $routes->add('cpscoping/is_candidate_insert/(:any)/(:any)', 'Cpscoping::cp_is_candidate_insert/$1/$2');
// $routes->add('cpscoping/is_candidate_control/(:any)', 'Cpscoping::cp_is_candidate_control/$1');
// $routes->add('cpscoping/cost_ep/(:any)/(:any)/(:any)', 'Cpscoping::cost_ep_value/$1/$2/$3');
// $routes->add('cpscoping/get_allo/(:any)/(:any)/(:any)/(:any)/(:any)', 'Cpscoping::get_allo_from_fname_pname/$1/$2/$3/$4/$5');
$routes->add('cpscoping/(:any)/(:any)/show', 'Cpscoping::cp_show_allocation/$1/$2');
// $routes->add('cpscoping/delete/(:any)/(:any)/(:any)', 'Cpscoping::delete_allocation/$1/$2/$3');
// $routes->add('cp_allocation_array/(:any)', 'Cpscoping::cp_allocation_array/$1');
// $routes->add('cpscoping/(:any)/(:any)/allocation', 'Cpscoping::cp_allocation/$1/$2');
// $routes->add('cpscoping/pro/(:any)', 'Cpscoping::p_companies/$1');

//Password routes
$routes->add('send_email_for_change_pass', 'Password::send_email_for_change_pass');
$routes->add('change_pass/(:any)', 'Password::change_pass/$1');
$routes->add('new_password_email', 'Password::new_password_email');
$routes->add('new_password/(:any)', 'Password::new_password/$1');

$routes->add('cluster', 'Cluster::cluster_to_match_company');

$routes->add('become_consultant', 'User::become_consultant');
$routes->add('profile_update', 'User::user_profile_update');
$routes->add('user/(:any)', 'User::user_profile/$1');
$routes->add('users', 'User::show_all_users');
$routes->add('register', 'User::user_register');
$routes->add('login', 'User::user_login');
$routes->add('logout', 'User::user_logout');

//OPen project
$routes->add('closeproject', 'Project::close_project');
$routes->add('openproject', 'Project::open_project');
$routes->add('update_project/(:any)', 'Project::update_project/$1');
$routes->add('newproject', 'Project::new_project');
$routes->add('projects', 'Project::show_all_project');
$routes->add('myprojects', 'Project::show_my_project');
$routes->add('contactperson', 'Project::contact_person');
$routes->add('project/(:any)', 'Project::view_project/$1');
$routes->add('deleteproject/(:any)', 'Project::delete_project/$1');
$routes->add('addConsultantToProject/(:any)', 'Project::addConsultantToProject/$1');

$routes->add('tuna_json/(:any)', 'Company::get_company_info/$1');
$routes->add('companySearch', 'Company::company_search');
$routes->add('update_company/(:any)', 'Company::update_company/$1');
$routes->add('newcompany', 'Company::new_company');
$routes->add('deletecompany/(:any)', 'Company::delete_company/$1');
$routes->add('companies', 'Company::show_all_companies');
$routes->add('mycompanies', 'Company::show_my_companies');
$routes->add('projectcompanies', 'Company::show_project_companies');
$routes->add('company/(:any)', 'Company::companies/$1');
$routes->add('addUsertoCompany/(:any)', 'Company::addUsertoCompany/$1');
$routes->add('removeUserfromCompany/(:any)/(:any)', 'Company::removeUserfromCompany/$1/$2');

$routes->add('search', 'Search::search_pro');
$routes->add('search/(:any)', 'Search::search_pro/$1');

// Dataset
$routes->add('deleteuserep/(:any)/(:any)', 'User::deleteUserEp/$1/$2');
$routes->add('datasetexcel', 'User::dataFromExcel');
$routes->add('uploadExcel', 'User::uploadExcel');
$routes->add('flow_and_component', 'Dataset::flow_and_component');
$routes->add('allocationlist/(:any)/(:any)', 'Cpscoping::allocationlist/$1/$2');
$routes->add('new_flow/(:any)', 'Dataset::new_flow/$1');
$routes->add('edit_flow/(:any)/(:any)/(:any)', 'Dataset::edit_flow/$1/$2/$3');
$routes->add('edit_component/(:any)/(:any)', 'Dataset::edit_component/$1/$2');
$routes->add('new_component/(:any)', 'Dataset::new_component/$1');
$routes->add('delete_flow/(:any)/(:any)', 'Dataset::delete_flow/$1/$2');
$routes->add('delete_component/(:any)/(:any)', 'Dataset::delete_component/$1/$2');
$routes->add('UBP_values', 'Dataset::UBP_values');

$routes->add('new_product/(:any)', 'Dataset::new_product/$1');
$routes->add('edit_product/(:any)/(:any)', 'Dataset::edit_product/$1/$2');
$routes->add('product', 'Dataset::product');
$routes->add('delete_product/(:any)/(:any)', 'Dataset::delete_product/$1/$2');

$routes->add('edit_process/(:any)/(:any)', 'Dataset::edit_process/$1/$2');
$routes->add('new_process/(:any)', 'Dataset::new_process/$1');
$routes->add('delete_process/(:any)/(:any)/(:any)', 'Dataset::delete_process/$1/$2/$3');
$routes->add('get_sub_process', 'Dataset::get_sub_process');
$routes->add('my_ep_values/(:any)/(:any)', 'Dataset::my_ep_values/$1/$2');
$routes->add('new_equipment/(:any)', 'Dataset::new_equipment/$1');
$routes->add('get_equipment_type', 'Dataset::get_equipment_type');
$routes->add('get_equipment_attribute', 'Dataset::get_equipment_attribute');
$routes->add('delete_equipment/(:any)/(:any)', 'Dataset::delete_equipment/$1/$2');

$routes->add('sendEmail', 'SendMail::index');
$routes->add('sendMail', 'SendMail::sendMail');

$routes->add('/', 'Homepage::index');
$routes->add('(:any)', 'Pages::view/$1');
$routes->add('404_override', '');
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

