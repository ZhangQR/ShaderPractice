Shader "ZhangQr/Water"
{
    Properties
    {
        _NormalMap("NormalMap",2D) = "white"{}
        _MainTexure("MainTexture",2D) = "white"{}
        _EnvirnmentCube("EnvirnmentCube",Cube) = "SkyBox"{}
        // _DiffuseRatio("DiffuseRatio",float) = 1
        _Schlick("Schlick",float) = 1
        _RefractionDistortion("RefractionDistortion",float) = 1
        _XSpeed("XSpeed",float) = 1
        _YSpeed("YSpeed",float) = 1
    }
    SubShader
    {
        // 透明保证在此之前场景内其他物品都被渲染（折射需要）
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
            //float _DiffuseRatio;
            float _Schlick;
            float _RefractionDistortion;
            float _XSpeed;
            float _YSpeed;

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
                float4 worldPosition : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.normal = v.normal;
                o.tangent = v.tangent;
                o.uv = v.uv;
                // 这是位置，不是方向，所以需要保留 4 位
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 speed = _Time.y * float2(_XSpeed,_YSpeed);
                fixed3 diffuse = tex2D(_MainTexure,i.uv + speed);
                fixed3 tangentNormal1 = UnpackNormal(tex2D(_NormalMap,i.uv + speed));
                fixed3 tangentNormal2 = UnpackNormal(tex2D(_NormalMap,i.uv - speed));
                fixed3 tangentNormal = normalize(tangentNormal1 + tangentNormal2);

                //把法线从切线空间转换到世界坐标
                float3 worldSpaceX = normalize(mul((float3x3)unity_ObjectToWorld,i.tangent));
                float3 worldSpaceZ = normalize(mul(i.normal,(float3x3)unity_WorldToObject));
                float3 worldSpaceY = cross(worldSpaceZ,worldSpaceX)*i.tangent.w;
                float3x3 transformMatrix = transpose(float3x3(worldSpaceX,worldSpaceY,worldSpaceZ));
                float3 worldSpaceNormal = mul(transformMatrix,tangentNormal);

                // 根据法线反射环境，这里的世界坐标保持 4 位数是有必要的，不能当成方向来做
                float3 worldSpaceViewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition.xyz / i.worldPosition.w));
                float3 relectionDir = reflect(-worldSpaceViewDir,worldSpaceNormal);
                fixed3 relectionCol = texCUBE(_EnvirnmentCube,relectionDir) * diffuse.xyz;
                
                // 计算折射
                float2 refractionOffset = i.screenUV.xy/i.screenUV.w;
                refractionOffset.xy += _RefractionDistortion * tangentNormal.xy;
                fixed3 refractionCol = tex2D(_RefractionTex,refractionOffset).xyz;
                
                // 使用 Schlick 菲涅耳近似等式来混合
                float f = _Schlick + (1 - _Schlick)*(pow(1 - max(0,dot(normalize(worldSpaceViewDir),worldSpaceZ)),4));
                fixed3 refractionAndReflection =  relectionCol * f + (1 - f) *  refractionCol;
                

                // 这种效果不好，还是把 diffuse 加在反射里面比较好
                //fixed3 finalCol = diffuse * _DiffuseRatio + (1 - _DiffuseRatio) * refractionAndReflection; 

                // 最后输出
                return fixed4(refractionAndReflection,0);
            }
            ENDCG
        }
    }
}
