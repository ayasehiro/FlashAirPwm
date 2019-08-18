-- FlashAir W-04 - PWM + Motor Driver
STATE_SPEED = 0
STATE_TR = 1
PWM_CH_R = 0
PWM_CH_L = 1
PWM_HZ = 490

function send_pwm(ch, hz, duty)
	if(duty == 0) then
	  res = fa.pwm("stop", ch)
	  print("pwm stop  ch[" .. ch .. "] res[" .. res .. "]")
	else
	  res = fa.pwm("duty", ch, hz, duty)
	  print("pwm       ch[" .. ch .. "] Hz[" .. hz .. "] Duty[" .. duty .. "] res[" .. res .. "]")
	  res = fa.pwm("start", ch)
	  print("pwm start ch[" .. ch .. "] res[" .. res .. "]")
	end
end

function controlSpeed(speednum, tr)
	if(speednum < 0) then return end
	if(speednum > 200) then return end
	if (tr == 1) then
	  send_pwm(PWM_CH_L, PWM_HZ, 0)
	  send_pwm(PWM_CH_R, PWM_HZ, speednum/2)
	else
	  send_pwm(PWM_CH_R, PWM_HZ, 0)
	  send_pwm(PWM_CH_L, PWM_HZ, speednum/2)
	end
end

function getSharedMem()
  local b = fa.sharedmemory("read", 0, 4)
  if (b == nil) then
    return 0
  else
    STATE_SPEED = tonumber(string.sub(b, 1, 3))
    STATE_TR  = tonumber(string.sub(b, 4, 4))
  end
  return 1
end

function initSharedMem()
  local c = fa.sharedmemory("write", 0, 13, "0000000000000")
  if (c ~= 1) then
    return 0
  end
  return 1
end

res = fa.pwm("init", PWM_CH_R, 1)
if(r ~= 1) then
  return
end
res = fa.pwm("init", PWM_CH_L, 1)
if(r ~= 1) then
  return
end

local r = initSharedMem()
if(r ~= 1) then
  return
end
sleep(1000)
while(1) do
  local tmp_spd = STATE_SPEED
  local tmp_tr = STATE_TR
  r = getSharedMem()
  if(r == 1) then
    if(tmp_spd ~= STATE_SPEED or tmp_tr ~= STATE_TR) then
      controlSpeed(STATE_SPEED, STATE_TR)
    end
  end
  sleep(100)
  collectgarbage("collect")
end


