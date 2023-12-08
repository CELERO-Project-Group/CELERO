<?php

namespace Config;

use Config\Database;
use App\Models\User_model;
use InvalidArgumentException;

class CustomValidation
{
    public function isTrueUserInfo(string $username, string &$error = null): bool
    {
        $request = \Config\Services::request();
        //$user_model = model(user_model::class);
        $user_model = new User_model();
        $userInfo = $user_model->check_user($username,md5($request->getPost('password')));

        if (!empty($userInfo) && is_array($userInfo)){
            return true;
        }else{
            $error = lang('Validation.wrongPassword');
            return false;
        }
    }
}