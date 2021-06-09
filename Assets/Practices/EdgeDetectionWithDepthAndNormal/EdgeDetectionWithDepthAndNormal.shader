Shader "ZhangQr/PostProcess/EdgeDetectionWithDepthAndNormal"
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            float _SampleDistance;
            half4 _Sensitivity;
            sampler2D _CameraDepthNormalsTexture;
            bool _UseDepth;
            bool _UseNormal;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv[0] = v.uv;
                float2 uv = v.uv;

                //#if UNITY_UV_STARTS_AT_TOP
                //if (_MainTex_TexelSize.y < 0)
                //    uv.y = 1 - uv.y;
                //#endif
                
                o.uv[1] = uv + _MainTex_TexelSize.xy * float2(-1,1)*_SampleDistance;
                o.uv[2] = uv + _MainTex_TexelSize.xy * float2(1,1)*_SampleDistance;
                o.uv[3] = uv + _MainTex_TexelSize.xy * float2(-1,-1)*_SampleDistance;
                o.uv[4] = uv + _MainTex_TexelSize.xy * float2(1,-1)*_SampleDistance;
                
                return o;
            }

            float2 HasEdge(half4 sample1,half4 sample2)
            {
                float depth1 = DecodeFloatRG(sample1.zw);
                float depth2 = DecodeFloatRG(sample2.zw);
                
                // 后面只需要判断法线是否相等，没有必要把观察空间下的法线求出来
                float2 normal1 = sample1.xy;
                float2 normal2 = sample2.xy;

                // 计算法线的差值
                float2 diff1 = abs(normal1 - normal2);

                // 法线差值简单相加即可
                return float2(abs(depth1 - depth2),diff1.x + diff1.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                half4 sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
                half4 sample2 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
                half4 sample3 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
                half4 sample4 = tex2D(_CameraDepthNormalsTexture,i.uv[4]);

                float2 edge = float2(0.0f,0.0f);
                
                // 用 Roberts 算子来计算，即左上角与右下角的差值乘右上角和左下角的差值。（这里改成了 + ，要更明显一点）
                edge += HasEdge(sample1,sample4);
                edge += HasEdge(sample2,sample3);
                edge *= _Sensitivity.xy;
                edge = step(1.0f,edge);
                
                fixed t = edge.x || edge.y;
                fixed4 colWithOrigin = lerp(tex2D(_MainTex,i.uv[0]),_EdgeColor,t);
                fixed4 colWithoutOrigin = lerp(_BackgroundColor,_EdgeColor,t);

                fixed4 col = lerp(colWithOrigin,colWithoutOrigin,_EdgeOnly);
                
                if(_UseDepth && _UseNormal)
                {
                    return col;
                }

                if(_UseDepth)
                {
                    colWithOrigin = lerp(tex2D(_MainTex,i.uv[0]),_EdgeColor,edge.x);
                    colWithoutOrigin = lerp(_BackgroundColor,_EdgeColor,edge.x);

                    col = lerp(colWithOrigin,colWithoutOrigin,_EdgeOnly);
                    return col;
                }

                if(_UseNormal)
                {
                    colWithOrigin = lerp(tex2D(_MainTex,i.uv[0]),_EdgeColor,edge.y);
                    colWithoutOrigin = lerp(_BackgroundColor,_EdgeColor,edge.y);

                    col = lerp(colWithOrigin,colWithoutOrigin,_EdgeOnly);
                    return col;
                }

                return col;
            }
            ENDCG
        }
    }
}
