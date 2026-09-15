package com.arquitectura.model;

public class Trabajo {
    private int id;
    private int usuarioId;
    private int unidad;
    private int sesion;
    private String archivoUrl;

    public Trabajo() {}

    public Trabajo(int id, int usuarioId, int unidad, int sesion, String archivoUrl) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.unidad = unidad;
        this.sesion = sesion;
        this.archivoUrl = archivoUrl;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }

    public int getUnidad() { return unidad; }
    public void setUnidad(int unidad) { this.unidad = unidad; }

    public int getSesion() { return sesion; }
    public void setSesion(int sesion) { this.sesion = sesion; }

    public String getArchivoUrl() { return archivoUrl; }
    public void setArchivoUrl(String archivoUrl) { this.archivoUrl = archivoUrl; }
}
