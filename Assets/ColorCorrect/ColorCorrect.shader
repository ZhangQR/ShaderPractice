Shader "ZhangQr/PostProcess/ColorCorrect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // ��Ϊ�Ǽ������������� Shader �Ľ�����ƣ����Բ���Ҫд
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite Off // ��Ȼ�����͸����������Ⱦ�ں���֮����ô�ͻ����
            Cull Off // ��ʵ����Ҳ���԰�
            ZTest Always // ��䲻д�Ļ��������ڱ༭��ģʽ�����У������ڽű���д�� [ExecuteInEditMode]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"



            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness; // ����
            float _Saturation; // ���Ͷ�
            float _Contrast; // �Ա�ɫ
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // ����
                fixed3 retCol = col.rgb * _Brightness;

                // �Աȶ� 
                float luminance = 0.2125f * col.r + 0.7154f * col.g + 0.0721f * col.b;
                fixed3 saturation = fixed3(luminance,luminance,luminance);
                retCol = lerp(saturation,retCol,_Saturation);
                
                // �Աȶ�
                fixed3 contrast = fixed3(0.5,0.5,0.5);
                retCol = lerp(contrast,retCol,_Contrast);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(retCol,col.a);
            }
            ENDCG
        }
    }
}
