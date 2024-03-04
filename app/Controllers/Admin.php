<?php

namespace App\Controllers;

class Admin extends BaseController
{

        public function index()
        {
                echo view('template/header');
                echo view('admin/admintools');
                echo view('template/footer');
        }

        public function report()
        {


                //print_r($session->get['user_in']['id']);
                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }
                $data['userName'] = $this->session->username;
                $data['role_id'] = $this->session->role_id;


                echo view('template/header_admin');
                echo view('admin/report', $data);
                echo view('template/footer_admin');
        }

        public function reportTest()
        {

                //print_r($session->get['user_in']['id']);
                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }
                $data['userName'] = $this->session->username;
                $data['role_id'] = $this->session->role_id;
                $data['userID'] = $this->session->id;


                echo view('template/header_admin', $data);
                echo view('admin/reportTest', $data);
                echo view('template/footer_admin');
        }

        public function newFlow()
        {


                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }
                $data['userName'] = $this->session->username;
                $data['role_id'] = $this->session->role_id;

                // check if the user has admin permissions (admin = 3)
                if ($data['role_id'] == "3") {

                        echo view('template/header_admin', $data);
                        echo view('admin/newFlow');
                        echo view('template/footer_admin');
                } else {

                        //TODO: create body with the information that you are not admin
                        return redirect()->to(site_url());
                }

        }

        public function newEquipment()
        {

                //print_r($session->get['user_in']['id']);
                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }
                $data['userName'] = $this->session->username;
                $data['role_id'] = $this->session->role_id;
                echo view('template/header_admin');
                echo view('admin/newEquipment', $data);
                echo view('template/footer_admin');
        }

        public function newProcess()
        {

                //print_r($session->get['user_in']['id']);
                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }
                $data['userName'] = $this->session->username;
                $data['role_id'] = $this->session->role_id;
                echo view('template/header_admin', $data);
                echo view('admin/newProcess', $data);
                echo view('template/footer_admin');
        }

        public function tooltip()
        {
                //echo view('template/header');
                echo view('isscoping/tooltip');
                //echo view('template/footer');
        }

        public function tooltipscenarios()
        {
                //echo view('template/header');
                echo view('isscoping/tooltipscenarios');
                //echo view('template/footer');
        }

        public function clusters()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/clusters', $data);
                echo view('template/footer_admin');
        }

        public function industrialZones()
        {


                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/industrialZones', $data);
                echo view('template/footer_admin');
        }

        public function reports()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;

                echo view('template/header_admin', $data);
                echo view('admin/reports', $data);
                echo view('template/footer_admin');
        }

        public function consultants()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;

                echo view('template/header_admin', $data);
                echo view('admin/consultants', $data);
                echo view('template/footer_admin');
        }

        public function employees()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/employees', $data);
                echo view('template/footer_admin');
        }

        public function rpEmployeesList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpEmployeesList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesList()
        {
                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesInfoList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesInfoList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesProjectsList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesProjectsList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesProjectDetailsList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesProjectDetailsList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesNotInClustersList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesNotInClustersList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesWasteEmissionList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesWasteEmissionList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesProductionList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesProductionList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesProcessesList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesProcessesList', $data);
                echo view('template/footer_admin');

        }

        public function rpConsultantsList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpConsultantsList', $data);
                echo view('template/footer_admin');

        }

        public function rpCompaniesInClustersList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpCompaniesInClustersList', $data);
                echo view('template/footer_admin');

        }

        public function rpEquipmentList()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/rpEquipmentList', $data);
                echo view('template/footer_admin');

        }


        public function zoneEmployees()
        {
                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/zoneEmployees', $data);
                echo view('template/footer_admin');

        }

        public function zoneCompanies()
        {

                $loginData = $this->session->get('role_id');
                if (empty($loginData)) {
                        return redirect()->to(site_url('login'));
                }

                $data['userID'] = $this->session->id;
                $data['userName'] = $this->session->username;
                echo view('template/header_admin', $data);
                echo view('admin/zoneCompanies', $data);
                echo view('template/footer_admin');

        }























}

