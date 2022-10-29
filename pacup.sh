#!/usr/bin/env bash

function usage() {
  cat <<EOM
使用方法: $(basename $0) [オプション]...
    -a          APTのみ実行
    -y		'y'の入力をスキップします
    -h          ヘルプを表示します
EOM
}

while (($#>0)); do
  case $1 in
    a|-a|--apt)
      PACUP_MOD="apt"
    ;;
    y|-y|--yes)
      PACUP_YES=" -y"
    ;;
    h|-h|--help)
      usage
      exit 0
    ;;
    *)
      usage
      exit 1
    ;;
  esac
  shift
done

function PACUP_APT() {
  echo -e "\napt-get update を実行します"
  sudo apt-get update
  echo -e "\napt-get full-upgrade$PACUP_YES を実行します"
  sudo apt-get full-upgrade$PACUP_YES
  echo -e "\napt-get autoremove$PACUP_YES を実行します"
  sudo apt-get autoremove$PACUP_YES
}

function PACUP_SYS() {
  if [ $(command -v snap) ]; then
    echo -e "\nsudo snap refresh を実行します"
    sudo snap refresh
  fi
  if [ $(command -v flatpak) ]; then
    echo -e "\nsudo flatpak update$PACUP_YES を実行します"
    sudo flatpak update$PACUP_YES
  fi
}

if [ "$PACUP_MOD" == "apt" ]; then
  sudo echo -n
  if [ $? != 0 ]; then
    echo -e "\nAPTコマンドの実行はRoot(管理者)権限を要求します｡\nもう一度お試しください｡\n"
    sudo echo -n
    if [ $? != 0 ]; then
      echo -e "\n権限の昇格に失敗したため､ 実行を終了しました｡"
      exit 1
    fi
  fi
  PACUP_APT
  exit 0
fi

sudo echo -n
if [ $? != 0 ]; then
  echo -e "\nRoot(管理者)権限を要求しています｡\nもう一度お試しください｡\n"
  sudo echo -n
  if [ $? != 0 ]; then
    echo -e "\n権限の昇格に失敗したため､ 実行を終了しました｡"
    exit 1
  fi
fi

PACUP_APT
if [ -f /usr/bin/flatpak ]; then
  echo -e "\nflatpak update$PACUP_YES を実行します"
  flatpak update$PACUP_YES
fi
PACUP_SYS
echo -e "\n完了しました！"
exit 0
