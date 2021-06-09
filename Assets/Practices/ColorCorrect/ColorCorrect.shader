Shader "ZhangQr/PostProcess/ColorCorrect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // 因为那几个参数不用在 Shader 的界面控制，所以不需要写
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite Off // 不然如果不透明的物体渲染在后处理之后，那么就会出错
            Cull Off // 其实不关也可以吧
            ZTest Always // 这句不写的话，不能在编辑器模式下运行，即便在脚本中写了 [ExecuteInEditMode]
            
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
            float _Brightness; // 亮度
            float _Saturation; // 饱和度
            float _Contrast; // 对比色
            
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

                // 亮度
                fixed3 retCol = col.rgb * _Brightness;

                // 对比度 
                float luminance = 0.2125f * col.r + 0.7154f * col.g + 0.0721f * col.b;
                fixed3 saturation = fixed3(luminance,luminance,luminance);
                retCol = lerp(saturation,retCol,_Saturation);
                
                // 对比度
                fixed3 contrast = fixed3(0.5,0.5,0.5);
                retCol = lerp(contrast,retCol,_Contrast);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(retCol,col.a);
            }
            ENDCG
        }
    }
}
