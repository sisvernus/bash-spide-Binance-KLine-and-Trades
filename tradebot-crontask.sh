exists=$(crontab -l | grep -i 'tradebot-crontask')
if [[ $exists == "" ]]; then
    crontab -l > mycron
    echo "0 */6 * * * \"bash ./tradebot-crontask_detail.sh\"" >> mycron
    crontab mycron
    rm mycron 
fi
