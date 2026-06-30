package com.alexander.sistema_cerro_verde_backend.dto.cajaresumen;

public class ResumenPagosDTO {
    private double efectivo = 0.0;
    private double yape = 0.0;
    private double plin = 0.0;
    private double tarjeta = 0.0;

    public double getEfectivo() { return efectivo; }
    public void setEfectivo(double efectivo) { this.efectivo = efectivo; }

    public double getYape() { return yape; }
    public void setYape(double yape) { this.yape = yape; }

    public double getPlin() { return plin; }
    public void setPlin(double plin) { this.plin = plin; }

    public double getTarjeta() { return tarjeta; }
    public void setTarjeta(double tarjeta) { this.tarjeta = tarjeta; }
}
