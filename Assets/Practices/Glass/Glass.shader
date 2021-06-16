Shader "ZhangQr/Glass"
{
    Properties
    {
        _NormalMap("NormalMap",2D) = "white"{}
        _MainTexure("MainTexture",2D) = "white"{}
        _EnvirnmentCube("EnvirnmentCube",Cube) = "SkyBox"{}
        _RelectionRatio("RelectionRatio",float) = 1
        _RefractionRatio("RefractionRatio",float) = 1
        _RefractionDistortion("RefractionDistortion",float) = 1
    }
    SubShader
    {
        // ͸����֤�ڴ�֮ǰ������������Ʒ������Ⱦ��������Ҫ��
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        LOD 100

        GrabPass{"_RefractionTex"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _MainTexure;
            float4 _MainTexure_ST;
            sampler2D _RefractionTex;
            samplerCUBE _EnvirnmentCube;
            float _RelectionRatio;
            float _RefractionRatio;
            float _RefractionDistortion;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float4 screenUV : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.normal = v.normal;
                o.tangent = v.tangent;
                o.uv = v.uv;
                o.worldPosition = mul((float3x3)unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 diffuse = tex2D(_MainTexure,i.uv);
                
                // ��Ҫ�����߿ռ��µķ���ת������������
                fixed3 tangentNormal = UnpackNormal(tex2D(_NormalMap,i.uv)); // �����ͼ����Ϊ�˷��߸�ʽ����ô��Ҫ�����������
                //fixed3 tangentNormal = fixed3(0,0,1); // �������Ե�
                //fixed3 tangentNormal = tex2D(_NormalMap,i.uv) * 2 - 1;  // �����ͼû������Ϊ���߸�ʽ����ô��ôд����(������Ҳ������ôд)

                //�ѷ��ߴ����߿ռ�ת������������
                float3 worldSpaceX = normalize(mul((float3x3)unity_ObjectToWorld,i.tangent));
                float3 worldSpaceZ = normalize(mul(i.normal,(float3x3)unity_WorldToObject));
                float3 worldSpaceY = cross(worldSpaceZ,worldSpaceX)*i.tangent.w;
                float3x3 transformMatrix = transpose(float3x3(worldSpaceX,worldSpaceY,worldSpaceZ));
                float3 worldSpaceNormal = mul(transformMatrix,tangentNormal);

                // ���ݷ��߷��价��
                float3 worldSpaceViewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                float3 relectionDir = reflect(-worldSpaceViewDir,worldSpaceNormal);
                fixed3 relectionCol = texCUBE(_EnvirnmentCube,relectionDir);

                // ��������
                float2 refractionOffset = i.screenUV.xy/i.screenUV.w;
                refractionOffset.xy += _RefractionDistortion * tangentNormal.xy;
                fixed3 refractionCol = tex2D(_RefractionTex,refractionOffset).xyz;
                
                // ���������ͼ�����䡢����
                fixed3 refractionAndReflection = refractionCol * _RefractionRatio + (1 - _RefractionRatio) * relectionCol;
                fixed3 finalCol = diffuse * _RelectionRatio + (1 - _RelectionRatio) * refractionAndReflection; 

                // ��֤����ת���Ƿ���ȷ
                //return fixed4(worldSpaceNormal.xyz * 0.5f + 0.5f,1);
                //return fixed4(worldSpaceNormal,1);

                // ������
                return fixed4(finalCol,0);
            }
            ENDCG
        }
    }
}
