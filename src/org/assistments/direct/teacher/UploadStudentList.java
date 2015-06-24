package org.assistments.direct.teacher;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.assistments.direct.LiteUtility;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

/**
 * Servlet implementation class UploadStudentList
 */
@WebServlet({"/UploadStudentList","/upload_student_list"})
public class UploadStudentList extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UploadStudentList() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		PrintWriter out = response.getWriter();
		String studentListFileName = request.getParameter("student_list_file_name");
		String fileName = studentListFileName.substring(studentListFileName.lastIndexOf('\\')+1);
		JsonArray studentList = new JsonArray();
		
		String filePath = LiteUtility.UPLOAD_DIRECTORY + "/" + fileName;
		FileReader fileReader = new FileReader(filePath);
		BufferedReader bufferedReader = new BufferedReader(fileReader);
		String line=null;
		while((line=bufferedReader.readLine())!=null){
			JsonObject jsonStudent = new JsonObject();
			jsonStudent.addProperty("first_name", line.substring(0,line.indexOf(',')));
			jsonStudent.addProperty("last_name", line.substring(line.indexOf(',')+1));
			studentList.add(jsonStudent);
			
		}
		bufferedReader.close();
		out.write(studentList.toString());
		out.flush();
		out.close();
		
	}

}
