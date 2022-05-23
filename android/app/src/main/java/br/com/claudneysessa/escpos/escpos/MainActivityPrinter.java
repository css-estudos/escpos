package br.com.claudneysessa.escpos.escpos;

import android.app.Activity;
import android.util.Base64;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.elgin.e1.Impressora.Termica;
import com.elgin.e1.Impressora.Utilidades.Inteiro;

import java.io.File;
import java.util.Map;

public class MainActivityPrinter {
    Activity mActivity;

    public MainActivityPrinter(Activity activity) {

        this.mActivity = activity;
        Termica.setContext(mActivity);

    }

    public String verificarStatusDoChannel(String mensagem) {

        return mensagem;

    }

    public int abrirConexaoInterna() {

        fecharConexao();

        int result = Termica.AbreConexaoImpressora(6, "M8", "", 0);

        return result;

    }

    public int abrirConexaoExterna(
            int tipo,
            String modelo,
            String conexao,
            int parametro) {

        fecharConexao();

        try {

            int result = Termica.AbreConexaoImpressora(
                    tipo,
                    modelo,
                    conexao,
                    parametro);

            return result;

        } catch (Exception e) {
            return abrirConexaoInterna();
        }
    }

    public int abrirConexaoExternaIp(
            String ip,
            int port) {

        fecharConexao();

        try {

            int result = Termica.AbreConexaoImpressora(3, "I9", ip, port);

            return result;

        } catch (Exception e) {
            return abrirConexaoInterna();
        }

    }

    public int abrirConexaoExternaBlueTooth(
            String modelo,
            String serial,
            int port) {

        fecharConexao();

        try {

            int result = Termica.AbreConexaoImpressora(
                    4,
                    modelo,
                    serial,
                    port);

            return result;

        } catch (Exception e) {
            return abrirConexaoInterna();
        }

    }

    public int fecharConexao() {

        int resultado = Termica.FechaConexaoImpressora();

        return resultado;

    }

    public int verificarStatusImpressora() {

        int resultado = Termica.StatusImpressora(3);

        return resultado;

    }

    public int avancarLinhas(Map map) {

        int lines = (Integer) map.get("quant");

        return Termica.AvancaPapel(lines);

    }

    public int cortarPapel(Map map) {

        int lines = (Integer) map.get("quant");

        return Termica.Corte(lines);

    }

    public int cortarPapelTotal(Map map) {

        int lines = (Integer) map.get("quant");

        return Termica.CorteTotal(lines);

    }

    public int imprimirTexto(Map map) {

        String text = (String) map.get("text");
        String align = (String) map.get("align");
        String font = (String) map.get("font");
        int fontSize = (Integer) map.get("fontSize");

        int result;

        int alignValue = 0;
        int styleValue = 0;

        // ALINHAMENTO VALUE
        if (align.equals("Esquerda")) {
            alignValue = 0;
        } else if (align.equals("Centralizado")) {
            alignValue = 1;
        } else {
            alignValue = 2;
        }

        // STILO VALUE
        if (font.equals("FONT B")) {
            styleValue += 1;
        }
        if ((boolean) map.get("isUnderline")) {
            styleValue += 2;
        }
        if ((boolean) map.get("isBold")) {
            styleValue += 8;
        }

        result = Termica.ImpressaoTexto(text, alignValue, styleValue, fontSize);
        return result;

    }

    public int imprimirEscPos(Map map) {

        byte[] writeData = (byte[]) map.get("data");
        int writeNum = (Integer) map.get("bytes");
        int readDataParam = (Integer) map.get("readData");
        int readNumParam = (Integer) map.get("readNum");
        byte[] readData = new byte[readDataParam];
        Inteiro readNum = new Inteiro(readNumParam);

        int ret = Termica.DirectIO(
                writeData,
                writeNum,
                readData,
                readNum);

        return ret;

    }

    private int codeOfBarCode(String barCodeName) {
        if (barCodeName.equals("UPC-A"))
            return 0;
        else if (barCodeName.equals("UPC-E"))
            return 1;
        else if (barCodeName.equals("EAN 13") || barCodeName.equals("JAN 13"))
            return 2;
        else if (barCodeName.equals("EAN 8") || barCodeName.equals("JAN 8"))
            return 3;
        else if (barCodeName.equals("CODE 39"))
            return 4;
        else if (barCodeName.equals("ITF"))
            return 5;
        else if (barCodeName.equals("CODE BAR"))
            return 6;
        else if (barCodeName.equals("CODE 93"))
            return 7;
        else if (barCodeName.equals("CODE 128"))
            return 8;
        else
            return 0;
    }

    public int imprimirCodigoDeBarras(Map map) {

        int barCodeType = codeOfBarCode((String) map.get("barCodeType"));
        String text = (String) map.get("text");
        int height = (Integer) map.get("height");
        int width = (Integer) map.get("width");
        String align = (String) map.get("align");

        int hri = 4; // NO PRINT
        int result;
        int alignValue;

        // ALINHAMENTO VALUE
        if (align.equals("Esquerda")) {
            alignValue = 0;
        } else if (align.equals("Centralizado")) {
            alignValue = 1;
        } else {
            alignValue = 2;
        }

        Termica.DefinePosicao(alignValue);

        result = Termica.ImpressaoCodigoBarras(barCodeType, text, height, width, hri);

        return result;

    }

    public int imprimirQRCode(Map map) {

        int size = (Integer) map.get("qrSize");
        String text = (String) map.get("text");
        String align = (String) map.get("align");
        int nivelCorrecao = 2;
        int result;
        int alignValue;

        // ALINHAMENTO VALUE
        if (align.equals("Esquerda")) {
            alignValue = 0;
        } else if (align.equals("Centralizado")) {
            alignValue = 1;
        } else {
            alignValue = 2;
        }

        Termica.DefinePosicao(alignValue);
        result = Termica.ImpressaoQRCode(text, size, nivelCorrecao);

        return result;

    }

    public int imprimirImagem(Map map) {

        String pathImage = (String) map.get("pathImage");
        boolean isBase64 = (boolean) map.get("isBase64");

        int result;

        File mSaveBit = new File(pathImage); // Your image file
        Bitmap bitmap;

        if (isBase64) {
            byte[] decodedString = Base64.decode(pathImage, Base64.DEFAULT);
            bitmap = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
        } else {
            String filePath = mSaveBit.getPath();
            bitmap = BitmapFactory.decodeFile(filePath);
        }

        result = Termica.ImprimeBitmap(bitmap);

        return result;

    }

    public int imprimirXmlNFCe(Map map) {

        String xmlNFCe = (String) map.get("xmlNFCe");
        int indexcsc = (int) map.get("indexcsc");
        String csc = (String) map.get("csc");
        int param = (int) map.get("param");

        return Termica.ImprimeXMLNFCe(xmlNFCe, indexcsc, csc, param);

    }

}
