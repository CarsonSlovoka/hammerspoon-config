-- every minute
spoon.Crontab.cron("* * * * *", function()
  hs.alert.show("cron test")
end)

-- 11:58
spoon.Crontab.cron("58 11 * * *", function()
  hs.alert.show("It's time to prepare for lunch", 10)
end)
