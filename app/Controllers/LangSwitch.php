<?php

namespace App\Controllers;

class LangSwitch extends BaseController
{
    public function __construct() {
        parent::__construct();
        $this->load->helper('url');
    }

    function switchLanguage($language = "") {
        $language = ($language != "") ? $language : "english";
        $session->set('site_lang', $language);
        redirect($_SERVER['HTTP_REFERER']);
    }
}