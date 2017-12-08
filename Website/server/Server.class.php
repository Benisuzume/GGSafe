<?php
require_once 'Database.class.php';

abstract class Request {
    const login = 1;
}

abstract class Account {
    const success  = 1;
    const disabled = 2;
    const banned   = 3;
}

class Server {
    private $request  = null;
    private $database = null;

    function __construct($request) {
        $this->request = json_decode($request);
        if ($this->request == null)
            throw new Exception('Invalid json.');

        if (!$this->isValidRequest())
            throw new Exception('Invalid request');

        try {
            $this->database = new Database();
        } catch (Exception $e) {
            throw $e;
        }

        echo $this->response();
    }

    private function response() {
        switch ($this->request->request)
        {
            case Request::login:
                return $this->login();
        }
    }

    private function login() {
        $appData = $this->database->getAppData();
        if ($appData['is_disabled'])
            return $this->disabled();

        $isBanned = $this->database->isBanned($this->request->username, $this->request->machine);
        if ($isBanned)
            return $this->banned();

        // $proxy = $this->getActiveProxy($appData['proxy']);

		list($ip, $port) = explode(':', $appData['proxy']);
		$proxy = array('ip' => $ip, 'port' => intval($port, 10));

        $rooms = $this->database->getRooms($this->request->username);

        $this->database->addLog($this->request->username, $this->request->machine);
		
		$blocks = $this->database->getBlocks();

        return $this->success($appData, $proxy, $rooms, $blocks);
    }

    private function success($appData, $proxy, $rooms, $blocks) {
        $response = array(
            'Result'        => Account::success,
            'LatestVersion' => $appData['latest_version'],
            'LatestUrl'     => $appData['download_url'],
            'Rooms'         => $rooms,
            'Blocks'        => $blocks,
            'Message'       => $appData['message'],
            'LanGameIp'     => gethostbyname('langame.auth.garenanow.com'),
            'ProxyIp'       => $proxy['ip'],
            'ProxyPort'     => $proxy['port'],
            'IpLookingUp'   => $appData['ip_looking_up'],
            'IpAddress'     => $_SERVER['REMOTE_ADDR']
            );
        return json_encode($response);
    }

    private function disabled() {
        $response = array(
            'Result' => Account::disabled
            );
        return json_encode($response);
    }

    private function banned() {
        $response = array(
            'Result' => Account::banned
            );
        return json_encode($response);
    }

    private function getActiveProxy($proxyList) {
        if (is_array($proxyList))
            $list = $proxyList;
        else
            $list = explode(PHP_EOL, $proxyList);

        $i = rand(0, count($list) - 1);
        list($ip, $port) = explode(':', $list[$i]);

        $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
        socket_set_option($socket, SOL_SOCKET, SO_SNDTIMEO, array('sec' => 2, 'usec' => 0));
        socket_set_option($socket, SOL_SOCKET, SO_RCVTIMEO, array('sec' => 2, 'usec' => 0));

        $result = @socket_connect($socket, $ip, $port);
        socket_close($socket);

        if ($result)
            return array('ip' => $ip, 'port' => intval($port, 10));
        else
        {
            unset($list[$i]);
            $list = array_values($list);

            return $this->getActiveProxy($list);
        }
    }

    private function isValidRequest() {
        if (!isset($this->request->request, $this->request->username, $this->request->machine))
            return false;

        if (!is_int($this->request->request) || $this->request->request != Request::login)
            return false;

        $this->request->username = preg_replace('/\s+/', '', $this->request->username);

        $len = strlen($this->request->username);
        if ($len < 1 || $len > 15)
            return false;

        $this->request->machine = preg_replace('/\s+/', '', $this->request->machine);

        if (strlen($this->request->machine) != 32)
            return false;

        return true;
    }
}