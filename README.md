# WSL2におけるUbuntu環境構築

## 1. WSL2のインストール

[こちらのリンク](https://docs.microsoft.com/ja-jp/windows/wsl/install-win10#manual-installation-steps)を参照  
インストールが完了したら、普通にUbuntuを更新する操作(emacsのインストールとか、build-essentialsのインストールとか)を行う。

### 1-1. 日本語環境作成

次の手順で行う。

1. 日本語パッケージのインストール  
`$ sudo apt -y install language-pack-ja`
2. ロケールを日本語に設定  
`$ sudo update-locale LANG=ja_JP.UTF8`
3. 日本語マニュアルのインストール  
`$ sudo apt -y install manpages-ja manpages-ja-dev`
4. wslの再起動(CTRL-D, 再起動)  
5. ロケールを確認

```text
$ locale  
LANG=ja_JP.UTF8
LANGUAGE=
LC_CTYPE="ja_JP.UTF8"
LC_NUMERIC="ja_JP.UTF8"
LC_TIME="ja_JP.UTF8"
LC_COLLATE="ja_JP.UTF8"
LC_MONETARY="ja_JP.UTF8"
LC_MESSAGES="ja_JP.UTF8"
LC_PAPER="ja_JP.UTF8"
LC_NAME="ja_JP.UTF8"
LC_ADDRESS="ja_JP.UTF8"
LC_TELEPHONE="ja_JP.UTF8"
LC_MEASUREMENT="ja_JP.UTF8"
LC_IDENTIFICATION="ja_JP.UTF8"
LC_ALL=
```

### 1-2. pyenvインストール

[こちら](https://github.com/pyenv/pyenv/)を参照。

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

折角滞りなく準備したのに、いよいよ `$ ssh my_account@192.168.1.5` をしてウンスンとかだとショックが大きい。そこで、余計なハマりを防止するための
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
***残念ながら、Windows Host-> WSL間のポートフォワーディングはTCPにしか対応していないことが分かった。SambaはUDPでの通信が必要なので、現状では
WSLにSambaサーバーを立てることは出来ない。以下、Sambaに関する記述は無視すること。***

### 4-1. WSL(Ubuntu)側にスタートアップスクリプトを用意する

このリポジトリにある`startup.sh`をUbuntuにインストールする。（ここでは、`/opt/bin`にインストールしたものとする。）§3でWSL上に立ち上げたSSHDへ接続する
手法について説明した。ここではその知見を基に、WSL上にsshd、smbd及びrsyslogdの各デーモンを自動起動するためのスクリプトを作成した。
このスクリプトでは、次の処理を行う。

1. WSLのIPアドレスを動的に求める。（WSLは起動するたびにIPアドレスが変化してしまうため、起動時に動的に取得しなければならない。）
1. ホストのIPアドレスからWSLのIPアドレスに対して、sshd、smbd及びrsyslogdで使うポートを転送する。
1. デーモンを起動する。

ここで1~2までは、Windowsのアプリケーションをbashから実行している。WSLのIPアドレスが起動するたびに変わってしまうため、仕方なくWSL側から実行する
形態になっている。ちょっとタコ仕様なので、そのうち改善されるのではないかな？

### 4-2. Windows起動時にWSLを起動してstartup.shを実行させる

幾つか方法はあると思うが、ここではタスクスケジューラーに登録したタスクで実現する。「タスク作成」タブで作成開始し、システム起動時に実行される
ようにスケジューリングしておけば良い。注意しなければいけないのは、「最上位の特権で実行する」を有効にしておくことである。  
タスクからはバッチを呼び出すか、または直接コマンドを実行することが出来るが、他に付随する処理に応じて選択すること。基本的には、次のコマンドが
実行されるようにしておけばどのような形態でも構わない。  
`c:\windows\system32\wsl.exe -d Ubuntu-18.04 -u root -- /opt/bin/startup.sh`  
ここにUbuntu-18.04はディストリビューション名である。環境に合わせて適宜変更すること。

## 5. WSLでpyenv管理下のpython scriptからsocketアクセスを可能にする

WSL側からのネットワーク資源へのアクセスには、基本的にroot権限が必要みたい。なので、通常のアプリからsocketを使うような場合は、sudoでの実行が必須となる。
ところが、sudoears設定はデフォルトでsecure_pathというものを定義しており、このパス以外のファイルに依存するようなソケットアプリケーションは
色々と不具合に見舞われる。pyenv環境下でpythonを実行している場合が、まさにそれに当たる。$HOME/.pyenv/を起点とする幾つかのディレクトリがパスに含まれていることを前提とするからである。これを回避するには/etc/sudoearsを編集してsecure_pathをコメントアウトすること。その上で、pythonをsudo経由で実行すればsocketアクセスが可能になる。

## 6. githubとの接続設定

githubリポジトリとpush/pull等のやり取りをするためには、Access tokenを効率的かつ安全に取り扱う必要がある。ここではgpgを用いて
tokenを暗号化し、比較的簡便に管理する方法について説明する。

### 6-1. gpgのinstall

ほぼ標準で同梱されているはずだが、もしなかったら `apt install gpg` でインストールする。

### 6-2. gpg keyの作成

gpgのuser-key pairがない場合は`gpg --gen-key`で作成する。この時username/mail-addrを設定するがメアドはkeyを取り出すときに必須となるので覚えておくこと。

### 6-3. Access tokenの取得

未取得であったら対象のリポジトリからAccess tokenを取得すること。方法に関しては[こちら](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)を参照のこと。

### 6-4. Credential helperの編集と登録

`.gpg-credential-helper.sh`を編集して6-2でgpg-keyを作成した時のメアドを`GPG_RECIPIENT`に割り当てる。また、githubへアクセスした証跡を記録するファイル名を`CRED_FILE`に設定する。最後に`git config --global credential.helper <PathToScript>`を実行して上記スクリプトを登録する。スクリプトに実行permissionを付与するのを忘れないように！！




