function decision_logic(label, conf)

if conf > 0.75
    disp("Operator Action: TRUST");
else
    disp("Operator Action: VERIFY / COLLECT MORE DATA");
end
end