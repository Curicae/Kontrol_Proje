function [output, integral_term, derivative] = pid_controller(error_signal, gains, previous_error, integral_term, time_step_size)
% pid_controller - PID kontrolcü hesaplar
% Girdiler:
%   error_signal: Hata sinyali (hedef - mevcut değer)
%   gains: PID kazançları (Kp, Ki, Kd)
%   previous_error: Önceki hata değeri
%   integral_term: İntegral terimi
%   time_step_size: Zaman adımı
% Çıktılar:
%   output: PID kontrolcü çıktısı
%   integral_term: Güncellenmiş integral terimi
%   derivative: Türev terimi

% Oransal terim
proportional = gains.Kp * error_signal;

% İntegral terimi (anti-windup ile)
integral_term = integral_term + gains.Ki * error_signal * time_step_size;
% İntegral terimini sınırla
integral_term = max(min(integral_term, 100), -100);

% Türev terimi
derivative = gains.Kd * (error_signal - previous_error) / time_step_size;

% Toplam çıktı
output = proportional + integral_term + derivative;

end 