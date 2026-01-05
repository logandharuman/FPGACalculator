function x = gen_signal(type, fs, t)

fc = 10e3; fm = 1e3;

switch type
    case "AM"
        m = cos(2*pi*fm*t);
        x = (1+0.7*m).*cos(2*pi*fc*t);

    case "FM"
        x = cos(2*pi*fc*t + 5*sin(2*pi*fm*t));

    case "PM"
        x = cos(2*pi*fc*t + 0.7*cos(2*pi*fm*t));

    case "DSBSC"
        x = cos(2*pi*fm*t).*cos(2*pi*fc*t);

    case "USB"
        x = real(hilbert(cos(2*pi*fm*t)).*exp(1j*2*pi*fc*t));

    case "LSB"
        x = real(hilbert(cos(2*pi*fm*t)).*exp(-1j*2*pi*fc*t));

    case "DIGITAL"
        bits = randi([0 1],1,length(t));
        x = pskmod(bits,2);     % BPSK
        x = real(x .* exp(1j*2*pi*fc*t));

    case "NOISE"
        x = randn(size(t));
end

x = x / max(abs(x));   % ±1 normalization (FPGA-SAFE)
end