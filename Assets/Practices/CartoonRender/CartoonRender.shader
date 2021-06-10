// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZhangQr/CartoonRender"
{
    Properties
    {
        _Ramp ("Ramp",2D) = "white"{}
        _OutlineColor ("OutlineColor",Color) = (1,1,1,1)
        _Outline ("Outline", float) = 1.0
        _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
        _Albedo ("Albedo",Color)=(1,1,1,1)
        _Spacular("Spacular",Color)=(1,1,1,1)
        _Gloss ("Gloss", float) = 1.0
        _SpecThreadhold ("SpecThreadhold", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            NAME "OUTLINE"
            CULL front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float _Outline;
            fixed4 _OutlineColor;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MV,v.vertex);
                float3 normal = mul(UNITY_MATRIX_IT_MV,v.normal);
                //normal.z = 0.5f;
                normal = normalize(normal);
                o.vertex.xyz += normal * _Outline;
                o.vertex = mul(UNITY_MATRIX_P,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        Pass
        {
            NAME "Cartoon"
            CULL back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _DiffuseColor;
            fixed4 _Spacular;
            fixed4 _Albedo;
            float _Gloss;
            float _SpecThreadhold;
            sampler2D _Ramp;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject)); // ���㷨��
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ������
                fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz *_Albedo;

                // �������
                float3 normal = i.worldNormal;
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float diff = saturate(dot(normal,worldLightDir));
                diff = diff * 0.75f + 0.25f; // �벨����
                fixed3 diffuseColor = _LightColor0.rgb * _Albedo * tex2D(_Ramp,float2(diff,0));

                // �߹ⷴ��
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz); // ����۲�ķ���
                float3 h_normal = normalize(viewDir.xyz + worldLightDir.xyz); // �����ӽǷ���͹�Դ������м䷽�������ͷ��ߵļн���ȷ����ǿ
                fixed spec = max(0,dot(normal,h_normal));
                
                //spec = step(_SpecThreadhold,spec); // ֱ������д���н����Եľ��

                //fixed w = fwidth(spec) * 2.0f; // ����д����ë�� // fwidth(spec) = abs(ddy(spec)) + abs(ddx(spec))
                //spec = smoothstep(_SpecThreadhold - w,_SpecThreadhold,spec);
                
                spec = smoothstep(_SpecThreadhold - 0.15f,_SpecThreadhold,spec); // ��������С��ʱ�򣬸����漸��û��
                                                                                    // ����������ʱ����б�Ե���䣬������
                
                
                                                                                    
                                                                                    //fixed w = abs(ddy(spec)) * abs(ddx(spec));
                //spec = smoothstep(_SpecThreadhold - w,_SpecThreadhold,spec);
                
                fixed3 spacularColor = _Spacular * spec;
                fixed3 color = ambientColor + diffuseColor + spacularColor;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
