## 1. WSL2のインストール
[こちらのリンク](https://docs.microsoft.com/ja-jp/windows/wsl/install-win10#manual-installation-steps)を参照  
インストールが完了したら、普通にUbuntuを更新する操作(emacsのインストールとか、build-essentialsのインストールとか)を行う。
## 2. systemdの起動
これをやらないと例えばrsyslogとかsambaとかをインストールしてサービスとして起動することが出来ない。  
まず準備として、[こちら](https://qiita.com/tabizou/items/f47983d1d327e6c5d5e1#ms%E3%81%AEkey%E3%81%A8product-repository%E3%82%92%E7%99%BB%E9%8C%B2%E3%81%99%E3%82%8B)
を参照して.NETのリポジトリを登録する。 
次に準備第二弾として`apt install daemonize`を実行する。  
次に、[こちら](https://www.school.ctc-g.co.jp/columns/miyazaki/miyazaki22.html)を参照してsystemdを設定する。  
インストールが成功し、上記設定によって無事にログオンタスクとして登録されたら、ログオンしなおすことで無事にsystemdが起動するはず。確認としては、wslを起動した時に、マシン名がxxx-wslに代わっていることと、`systemctl status`を実行するとまともな出力がされること。なお、`systemctl`実行の際は、sudoを付けないこと。
