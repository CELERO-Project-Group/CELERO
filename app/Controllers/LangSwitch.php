<?php

namespace App\Controllers;

class LangSwitch extends BaseController
{
    function switchLanguage($language = "") {
        $language = ($language != "") ? $language : "english";
        $session->set('site_lang', $language);
        redirect($_SERVER['HTTP_REFERER']);
    }
}