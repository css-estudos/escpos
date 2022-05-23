package br.com.claudneysessa.escpos.escpos;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;

import android.graphics.Typeface;

import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.AsyncTask;

import java.io.IOException;

import java.util.Iterator;
import java.util.Vector;
import java.util.HashMap;

import android.view.View;

import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;

import java.io.IOException;

public class MainActivityPrinterChannel {

    private static final String ElginPrinterChannel = "br.com.sacfiscal.pdvandroid_flutter/printer";

    public MainActivityPrinterChannel(Context context, FlutterEngine flutterEngine, Activity activity){

        new MethodChannel(flutterEngine.getDartExecutor(), ElginPrinterChannel).setMethodCallHandler(
            new MethodCallHandler() {
                @Override
                public void onMethodCall(MethodCall call, Result result) {

                    MainActivityPrinter printer;
                    printer = new MainActivityPrinter(activity);

                    switch (call.method) {

                            case "verificarStatusDoChannel":
                                try {
                                    HashMap map = call.argument("args");
                                    String mensagem = (String) map.get("mensagem");
                                    result.success(printer.verificarStatusDoChannel(mensagem));
                                } catch (Exception e) {
                                    result.error( "printer_error_verificarStatusDoChannel", e.toString(), false );
                                }
                                break;

                            case "abrirConexaoInterna":
                                try {
                                    int resultado = printer.abrirConexaoInterna();
                                    result.success(resultado);
                                } catch (Exception e) {
                                    result.error( "printer_error_abrirConexaoInterna", e.toString(), false );
                                }
                                break;

                            case "abrirConexaoExterna":
                                try {
                                    HashMap map = call.argument("args");
                                    int tipo = (int) map.get("tipo");
                                    String modelo = (String) map.get("modelo");
                                    String conexao = (String) map.get("conexao");
                                    int parametro = (int) map.get("parametro");
                                    int resultado = printer.abrirConexaoExterna(tipo,modelo,conexao,parametro);
                                    result.success(resultado);
                                } catch (Exception e) {
                                    result.error( "printer_error_abrirConexaoExterna", e.toString(), false );
                                }
                                break;

                            case "abrirConexaoExternaIp":
                                try {
                                    HashMap map = call.argument("args");
                                    String ip = (String) map.get("ip");
                                    int port = (int) map.get("port");
                                    int resultado = printer.abrirConexaoExternaIp(ip, port);
                                    result.success(resultado);
                                } catch (Exception e) {
                                    result.error( "printer_error_abrirConexaoExterna", e.toString(), false );
                                }
                                break;

                            case "abrirConexaoExternaBlueTooth":
                                try {
                                    HashMap map = call.argument("args");
                                    String modelo = (String) map.get("modelo");
                                    String serial = (String) map.get("serial");
                                    int port = (int) map.get("port");
                                    int resultado = printer.abrirConexaoExternaBlueTooth(modelo, serial, port);
                                    result.success(resultado);
                                } catch (Exception e) {
                                    result.error( "printer_error_abrirConexaoExterna", e.toString(), false );
                                }
                                break;

                            case "fecharConexao":
                                try {
                                    int resultado = printer.fecharConexao();
                                    result.success(resultado);
                                } catch (Exception e) {
                                    result.error( "printer_error_fecharConexao", e.toString(), false );
                                }
                                break;                                

                            case "verificarStatusImpressora":
                                try {
                                    int resultado = printer.verificarStatusImpressora();
                                    result.success(resultado);
                                } catch (Exception e) {
                                    result.error( "printer_error_verificarStatusImpressora", e.toString(), false );
                                }
                                break;

                            case "avancarLinhas":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.avancarLinhas(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_avancarLinhas", e.toString(), false );
                                }
                                break;

                            case "cortarPapel":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.cortarPapel(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_cortarPapel", e.toString(), false );
                                }
                                break;

                            case "cortarPapelTotal":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.cortarPapelTotal(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_cortarPapelTotal", e.toString(), false );
                                }
                                break;

                            case "imprimirTexto":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.imprimirTexto(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_imprimirTexto", e.toString(), false );
                                }
                                break;

                            case "imprimirEscPos":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.imprimirEscPos(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_imprimirTexto", e.toString(), false );
                                }
                                break;

                            case "imprimirCodigoDeBarras":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.imprimirCodigoDeBarras(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_imprimirCodigoDeBarras", e.toString(), false );
                                }
                                break;

                            case "imprimirQRCode":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.imprimirQRCode(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_imprimirQRCode", e.toString(), false );
                                }
                                break;

                            case "imprimirImagem":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.imprimirImagem(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_imprimirImagem", e.toString(), false );
                                }
                                break;

                            case "imprimirXmlNFCe":
                                try {
                                    HashMap map = call.argument("args");
                                    result.success(printer.imprimirXmlNFCe(map));
                                } catch (Exception e) {
                                    result.error( "printer_error_imprimirXmlNFCe", e.toString(), false );
                                }
                                break;

                    }
                }
            }
        );
    }

}