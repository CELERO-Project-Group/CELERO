<?php

namespace App\Controllers;

class Isscoping extends BaseController
{

    public function index()
    {
        //print_r($session->get['user_in']);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != '3') {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        echo view('template/header');
        echo view('isscoping/index');
        echo view('template/footer');
    }

    public function auto()
    {
        //print_r($session->get['user_in']);
        $data['userID'] = $session->get['user_in']['id'];

        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != '3') {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        echo view('template/header');
        echo view('isscoping/auto', $data);
        echo view('template/footer');
    }

    public function autoprjbaseMDF()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $project_id = $session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        echo view('template/header');
        echo view('isscoping/autoprojectbaseMDF', $data);
        echo view('template/footer');
    }

    public function autoprjbaseMDFTest()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        echo view('template/header');
        echo view('isscoping/autoprojectbaseMDF_test', $data);
        echo view('template/footer');
    }

    public function autoprjbase()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        echo view('template/header');
        echo view('isscoping/autoprojectbase', $data);
        echo view('template/footer');
    }

    public function prjbaseMDF()
    {
        //print_r($session->get);
        //print_r($session->get['user_in']['id']);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }


        $project_id = $session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        echo view('template/header');
        echo view('isscoping/projectbaseMDF', $data);
        echo view('template/footer');
    }

    public function prjbase()
    {
        //print_r($session->get);
        //print_r($session->get['user_in']['id']);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        echo view('template/header');
        echo view('isscoping/projectbase', $data);
        echo view('template/footer');
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

    public function isscenarios()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }


        $project_id = $session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        echo view('template/header');
        echo view('isscoping/isscenarios', $data);
        echo view('template/footer');
    }

    public function isscenariosCns()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        
        $project_id = $session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        echo view('template/header');
        echo view('isscoping/isscenariosCns', $data);
        echo view('template/footer');
    }

}
