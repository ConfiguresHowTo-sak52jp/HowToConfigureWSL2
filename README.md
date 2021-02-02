## 1. WSL2のインストール
[こちらのリンク](https://docs.microsoft.com/ja-jp/windows/wsl/install-win10#manual-installation-steps)を参照  
インストールが完了したら、普通にUbuntuを更新する操作(emacsのインストールとか、build-essentialsのインストールとか)を行う。

## 2. Windows Defenderのファイアウォール設定を変更
インストールしたWSL2でネットワーク系のアプリ（sshd,rsyslog,samba等）を動作させて他のホストからリモート接続したい時は、
ファイアウォールの設定を変更しないと、基本、跳ねられると考えた方が良い。  
歯車アイコンから「更新とセキュリティ」⇒「Windowsセキュリティ」⇒「ファイアウォールとネットワークの保護」を開き、
「詳細設定」を選ぶ。後は、「受信の規則」⇒「規則の追加」で「規則の種類=ポート」を選択する。内容は直感的に設定して
いけば大体OK。

## 3. 少なくともリモートでSSH接続はしたい！
WSL2は論理ネットワークアダプタを有し、ホストアダプターへの接続はNATオンリーである。VirtualBoxやVMWareのようにツールでホストアダプター
へブリッジするような技は使えない。従って、他のホストからのリモート接続はホストPCからWSL2へ渡した転送ポート経由となる。WSL2に立てた
SSHサーバーへリモート接続するための手続き一切が[このサイト](https://qiita.com/yabeenico/items/15532c703974dc40a7f5)にまとめられている。
他のサーバー系アプリ（smbd,rsyslog等）に対しても全く同じ考え方で対応可能なので、上記を参照して、まずはSSH接続を確立するとよい。
### 3-1. あとで躓かないためのsshd設定
折角滞りなく準備したのに、いよいよ `$ ssh chara@192.168.1.5` をしてウンスンとかだとショックが大きい。そこで、余計なハマりを防止するための
最低限の設定をしてしまおう！
#### sshdに必要なHostキーの作成
`$ sudo ssh-keygen -A`を実行するだけ。
#### /etc/ssh/sshd_configの編集
- パスワードでのログイン許可：`PasswordAuthentication yes`
- rootでのログイン許可：     `PermitRootLogin yes`

## 4. Windowsログイン時にsshd、smbd及びrsyslogを自動起動する
§3でSSHの準備を整え、[ここ](https://github.com/ConfiguresHowTo-sak52jp/HowToConstructSamba.git)を参照してsambaを立ち上げ、さらに
[ここ](https://github.com/CSharpExpAndLibs/LogServerExp.git)を参照してsyslogの設定が完了したとして、Windowsログオン時にWSL2を起動し、
同時にsshd、smbd及びsyslogサービスを有効にするための手法について説明する。
