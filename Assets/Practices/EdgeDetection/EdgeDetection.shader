Shader "ZhangQr/PostProcess/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite Off ZTest Off Cull Off
            
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
                half2 uv[9]: TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            half4 _MainTex_TexelSize;
            float _EdgeLevel;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // 算出卷积核 9 个 uv,这边要按照顺序写
                o.uv[0] = v.uv + _MainTex_TexelSize.xy * float2(-1,1);
                o.uv[1] = v.uv + _MainTex_TexelSize.xy * float2(0,1);
                o.uv[2] = v.uv + _MainTex_TexelSize.xy * float2(1,1);
                o.uv[3] = v.uv + _MainTex_TexelSize.xy * float2(-1,0);
                o.uv[4] = v.uv + _MainTex_TexelSize.xy * float2(0,0);
                o.uv[5] = v.uv + _MainTex_TexelSize.xy * float2(1,0);
                o.uv[6] = v.uv + _MainTex_TexelSize.xy * float2(-1,-1);
                o.uv[7] = v.uv + _MainTex_TexelSize.xy * float2(0,-1);
                o.uv[8] = v.uv + _MainTex_TexelSize.xy * float2(1,-1);
                return o;
            }

            // 计算灰度值
            fixed luminance(fixed4 color) 
            {
                return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
            }
             
            half Sobel(v2f i)
            {
                const half Gx[9]=
                {
                    -1, -2, -1,
                    0,  0,  0,
                    1,  2,  1
                };
                
                const half Gy[9]=
                {
                    -1, 0,  1,
                    -2, 0,  2,
                    -1, 0,  1
                };

                float totalGx = 0;
                float totalGy = 0;
                for(int ii=0; ii<9; ++ii)
                {
                    fixed current = luminance(tex2D(_MainTex,i.uv[ii]));
                    totalGx += current * Gx[ii];
                    totalGy += current * Gy[ii];
                }
                return abs(totalGx) + abs(totalGy);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float edge = pow(Sobel(i),_EdgeLevel);
                fixed4 col1 = lerp(_BackgroundColor,_EdgeColor,edge);
                fixed4 col2 = lerp(tex2D(_MainTex, i.uv[4]),_EdgeColor,edge);
                return lerp(col2,col1,_EdgeOnly);
            }

            ENDCG
        }
    }
}
