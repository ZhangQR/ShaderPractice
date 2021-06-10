using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Text.RegularExpressions;

public class MotionBlurCameraMove : MonoBehaviour
{
    public Transform StartPoint;
    public Transform EndPoint;
    public Transform Center;
    public float MoveSpeed;
    private void Start()
    {
        transform.position = StartPoint.position;
    }
    void Update()
    {
        float time = Time.time;
        int second = int.Parse(Regex.Match(time.ToString(), @"\d*").Value);
        float frac = time - second;
        Vector3 Pingpong = second % 2 == 1 ? StartPoint.position : EndPoint.position;
        transform.position = Vector3.Slerp(transform.position - Center.position, 
            Pingpong - Center.position, 0.2f * MoveSpeed) + Center.position;
        transform.LookAt(Center.position);
    }
}
